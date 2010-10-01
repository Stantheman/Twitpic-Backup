Twitpic Backup Script -- Stan Schwertly
=======================================

This script downloads the full JPGs from a Twitpic account, taking a username and output directory as arguments. Example:

sh twitpic.sh MLACitation output-twitpic

Three directories are created within the "outpput-twitpic": "html", "images", and "logs"

This script is inspired by and derived from the script over at TuxBox by "burndive": http://tuxbox.blogspot.com/2010/03/twitpic-to-posterous-export-script.html

He developed a script that pulled information from Twitpic and imported it into Posterous. It pulls the HTML pages and processes them, pulling down the thumbnail, the scaled version, and the full version, along with a .txt file with the caption sent with it. I only want the JPG, so I've modified the script accordingly. His original design is cron-friendly, which I've kept for my own backups.

I have a few extra ideas for this as it goes, but this is my first real dealing with a bash script, so it's all learning from here out! The GitHub link for this is: http://github.com/Stantheman/Twitpic-Backup, and my website can be found at: http://www.schwertly.com/