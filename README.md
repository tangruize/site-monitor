# Site Monitor

I don't want to miss any news about the websites I'm interested in.
So I write a script to monitor changes to those sites.

The idea is very simple:

- wget site.html
- git add && git commit
- if git commit succeeds, notify me!

This script only works on Linux, but it can be easily implemented on other platforms.
I am not intended to make it portable.

## Dependency

The script uses `git`, `notify-send` and `wget`.

```bash
sudo apt install libnotify-bin  # for notify-send
```

## Usage

I want to get latest news of [NJU CS](https://cs.nju.edu.cn/).

```bash
./site-monitor.sh https://cs.nju.edu.cn/1654/list.htm
```

Running this cmd will create a directory named `cs.nju.edu.cn@1654@list.htm`.
The directory name is the site url after replacing `@` with `/`.

Then run `./site-monitor.sh` will check all sites in the script directory.

I want to monitor [LAMDA publication list](http://www.lamda.nju.edu.cn/CH.Pub.ashx).
However, it is a dynamic page and every time re-run `./site-monitor.sh` will send a notification.
Just use `git log -p` to observe the differences and write a `rules.sh` to delete volatile lines:

```bash
./site-monitor.sh http://www.lamda.nju.edu.cn/CH.Pub.ashx

cat << EOF > www.lamda.nju.edu.cn@CH.Pub.ashx/rules.sh
sed -i '/hidden/d' CH.Pub.ashx
EOF

chmod +x www.lamda.nju.edu.cn@CH.Pub.ashx/rules.sh
```



## Schedule

Better use with cron.
I schedule it every hour.
And here is my crontab:

```crontab
# m h  dom mon dow   command
  0 *   *   *   *    /path/to/site-monitor.sh
```

You can also set it to start automatically when login:

```bash
cat << EOF > "$HOME/.config/autostart/site-monitor.desktop"
[Desktop Entry]
Type=Application
Exec=bash -c 'sleep 30 && `realpath site-monitor.sh`'
Name=site-monitor
Hidden=false
X-GNOME-Autostart-enabled=true
Comment=Monitor websites and notify the latest news
EOF
```

## Disclaimer

Since it uses git, histories are saved.
You should respect the privacy of the website owner.
