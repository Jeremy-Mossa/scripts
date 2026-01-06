#!/usr/bin/env perl
use 5.42.0;
use autodie;
use File::Temp qw(tempdir);
use Selenium::Remote::Driver;

#--------------------------- Internet Check ----------------------------

while (1) {
    if (system("/bin/ping -c 2 8.8.8.8 > /dev/null 2>&1") == 0) {
        last;
    }
    sleep 60;
}

#-----------------------------------------------------------------------


# Clean up any old processes
system("pkill Xvfb");
system("pkill geckodriver");
system("pkill firefox");
sleep 2;

# Start Xvfb
system("Xvfb :99 -ac -screen 0 1920x1200x24 >/dev/null 2>&1 &");
sleep 5;
# Set DISPLAY and force X11 for Xvfb
$ENV{DISPLAY} = ":99";
$ENV{MOZ_ENABLE_WAYLAND} = 0;

#-------------------------- Screen Recording ---------------------------

my $resolution = "1920x1200";
my $output_file = "$ENV{HOME}/Downloads/webstore_recording.mp4";

# Start ffmpeg recording
my $ffmpeg_pid = fork();
if (!$ffmpeg_pid) {
    exec(
        "ffmpeg -y " .
        "-f x11grab " .
        "-video_size $resolution " .
        "-framerate 30 " .
        "-i :99 " .
        "-c:v libx264 " .
        "-preset fast " .
        "-crf 23 " .
        "-pix_fmt yuv420p " .
        "$output_file"
    );
    exit;
}

#-----------------------------------------------------------------------


# Start geckodriver in background
my $gecko_pid = fork() // die "Cannot fork: $!";
if ($gecko_pid == 0) {
    exec("geckodriver --port 4444 >/dev/null 2>&1");
    die "Cannot exec geckodriver: $!";
}
sleep 5;  # Give geckodriver time to start

# Read credentials
my $username_file = "$ENV{HOME}/.ssh/mcoc_username";
open(my $username_fh, '<', $username_file) or die "Cannot open $username_file: $!";
my $username = <$username_fh>;
chomp($username) if defined $username;
close($username_fh);

my $password_file = "$ENV{HOME}/.ssh/mcoc_password";
open(my $password_fh, '<', $password_file) or die "Cannot open $password_file: $!";
my $password = <$password_fh>;
chomp($password) if defined $password;
close($password_fh);

my $url = "https://api.production.auth.pubsdk.kabam.dev/v1/kid/account/login";

# Create Selenium driver
my $driver = Selenium::Remote::Driver->new(
    remote_server_addr => 'localhost',
    port               => 4444,
    browser_name       => 'firefox',
    extra_capabilities => {
        'moz:firefoxOptions' => {
            args => [
                '--private-window',
                '--window-size=1920,1200',
                '--new-instance' # if firefox alread running elsewhere
            ],
            prefs => {
                'browser.privatebrowsing.autostart' => 1
            }
        }
    }
);

# Helper for explicit waits
sub wait_for {
    my ($driver, $code, $timeout) = @_;
    $timeout //= 60;
    my $start = time;
    while (time - $start < $timeout) {
        if (eval { $code->(); 1 }) {
            return;
        }
        sleep 1;
    }
    die "Timeout waiting for condition";
}

$driver->get($url);
wait_for $driver, sub { $driver->get_title() =~ /Account Login/i };

# wait_for $driver, sub { $driver->find_element('[data-testid="login-form__primary-social"] button.primary-social__kabam') };
# $driver->find_element('[data-testid="login-form__primary-social"] button.primary-social__kabam')->click();

# Fill credentials (adjust selectors if needed based on actual page inspection)
wait_for $driver, sub { $driver->find_element('//input[@type="email" or @id="email" or @name="email"]') };
my $email_field = $driver->find_element('//input[@type="email" or @id="email" or @name="email"]');
$email_field->send_keys($username);

my $pass_field = $driver->find_element('//input[@type="password"]');
$pass_field->send_keys($password);

# Submit (adjust selector if button text differs)
my $submit_btn = $driver->find_element('//button[@type="submit" or contains(translate(text(),"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz"),"log in")]');
$submit_btn->click();

sleep 7;  # Keep your original delay; replace with element wait if possible

$driver->execute_script(q{
    document.querySelectorAll("span[data-testid='get-free']").forEach(el => el.click());
});

sleep 5;

# Cleanup
$driver->quit();

# Stop geckodriver
kill 'INT', $gecko_pid;
waitpid $gecko_pid, 0;

# Stop ffmpeg
kill 'INT', $ffmpeg_pid;
waitpid $ffmpeg_pid, 0;

# Kill Xvfb
system("pkill Xvfb");
