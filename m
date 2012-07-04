From: M.Mohan Kumar <mohan@in.ibm.com>
Date: Wed, 04 Jul 2012 23:02:11 +0530
Subject: lvm2-api usage in GlusterFS
Message-ID: <87txxnqvok.fsf@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hello,

I am working on adding a GlusterFS feature to enable exporting Logical
volumes as regular files to GlusterFS client. Here is the link for the
patches:
       http://review.gluster.com/3551

GlusterFS patches use lvm2-devel library to find out list of logical
volumes for the given volume group and creating LVs etc.

When open request comes in the gluster mount path, server side code
opens the intended LV by using this logic: /dev/<vg-name>/<lv-name>.
This path is actually a symbolic link to /dev/dm-<x>. Is my assumption
about having this /dev/<vg-name>/<lv-name> is it right? Will it
always work?

Also other issues with the patch is resizing and creating a snapshot
of LV. There is no API to resize a LV and as of now I am using the
lvresize binary to resize the LV by forking and executing it. Also when
creating a snapshot of LV, I am forking and executing lvcreate binary
with appropriate parameters.

Is there any plan to add support to resize a LV and create snapshot of
LV?

Regards,
M. Mohan Kumar.


