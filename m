From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  1 Apr 2010 17:57:26 -0400
Subject: [PATCH 0/6] Add pv->vg link, rework lvm2app string properties
Message-ID: <1270159052-1181-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patchset adds a pv->vg link and reworks lvm2app string property
functions to use the vg handle's memory for allocation.

The first 3 patches are simple refactorings, the 4th patch adds the
pv->vg link, and the last 2 change lvm2app string functions and the
lvm2app version number.


