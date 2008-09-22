From: Benjamin Schweizer <2008@benjamin-schweizer.de>
Date: Mon, 22 Sep 2008 15:17:26 +0200
Subject: dsnapshot, a high-level interface to the snapshot facility
Message-ID: <20080922131726.GD21738@sickos.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello there,

recently, I've written a helper script that I use with my rsync-based
backups. Here's the abstract:

| The dsnapshot script provides a high-level interface to the Linux
| Logical Volume Manager. It uses its block-level snapshot support to
| create directory snapshots. In contrast to block-level snapshots,
| directory snapshots resemble the file system layer. Thus, you can
| snapshot any directory that is on a logical volume and you don?t have to
| worry about the actual logical volumes, mount points and paths.

And this is the actual syntax for creating...

| $ dsnapshot --create /srv/mysql/test/
| /var/lib/dsnapshot/srv-fdf2e6dc/mysql/test/

... and removing a directory snapshot

| $ dsnapshot --remove /var/lib/dsnapshot/srv-fdf2e6dc/mysql/test/

I've found it very handy when you need to backup partial directories and
not the whole volume. Some people use it to backup the disk images of
running virtual machines, I use it with mailstores and small databases.

The script can be found here [ http://benjamin-schweizer.de/files/dsnapshot/ ]
and an introduction there [ http://benjamin-schweizer.de/dsnapshot.html ].
If you like it and find it useful, I'd like to see it in the /contrib directory.


Greetings
Benjamin

-- 
http://benjamin-schweizer.de/contact


