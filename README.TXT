Twitpic Backup Script -- Stan Schwertly
=======================================

This script downloads the full JPGs from a Twitpic account, taking a username and output directory as arguments. Example:

sh twitpic.sh MLACitation output-twitpic

This script is inspired by and derived from the script over at TuxBox by "burndive": http://tuxbox.blogspot.com/2010/03/twitpic-to-posterous-export-script.html

He developed a script that pulled information from Twitpic and imported it into Posterous. It pulls the HTML pages and processes them, pulling down the thumbnail, the scaled version, and the full version, along with a .txt file with the caption sent with it. 

I only want the JPG, so I've modified the script accordingly. It also splits the output into subdirectories, "images" and "html". It checks for existence of the HTML file to save on bandwidth and only downloads when necessary. It's cron-friendly.

I have a few extra ideas for this as it goes, but this is my first real dealing with a bash script, so it's all learning from here out!

Stan Schwertly