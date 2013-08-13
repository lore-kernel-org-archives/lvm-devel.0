From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 13 Aug 2013 19:36:04 +0100
Subject: Are there race conditions between pvcreate and vgcreate?
In-Reply-To: <520A7350.3080005@mglug.de>
References: <520A7350.3080005@mglug.de>
Message-ID: <20130813183604.GB29268@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Aug 13, 2013 at 07:56:32PM +0200, Oliver Rath wrote:
> i have a strange problem:
 
When you see anything strange, add -vvvv to all your commands
and record the output, or configure lvm.conf to write it all
to syslog, if you have things running in parallel and need
to see how they overlap.

> vgcreate myvg /dev/sda5 /dev/sdb1

vgcreate will perform pvcreate itself if necessary.
Try without the pvcreates?

Alasdair


