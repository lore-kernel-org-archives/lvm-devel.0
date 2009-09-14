From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 14 Sep 2009 15:14:47 -0400
Subject: [PATCH 0/3]: Clarify partial, add vg_attr 'get' functions to lvm2app
Message-ID: <1252955690-25500-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


These patches add the most useful 'vg_attr' fields as lvm2app 'get' functions.
First patch clarifies that a 'partial' VG is one which has one or more missing
PVs.  The second patch adds the lvm2app functions.  The third patch is just
cleanup.


