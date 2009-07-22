From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 14:36:04 -0400
Subject: [PATCH 0/2] Add lvm_vg_open and update test/api/vgtest.c
Message-ID: <1248287766-11552-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset adds lvm_vg_open to liblvm and updates the simple vg unit
test.  Although we do not use 'flags' today it may be useful in the future
for something like NONBLOCKING locks or other flags currently used in vg_read
interface.


