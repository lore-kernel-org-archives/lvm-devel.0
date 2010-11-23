From: Dave Wysochanski <wysochanski@pobox.com>
Date: Tue, 23 Nov 2010 00:01:08 -0500
Subject: [PATCH 0/2] Update errno codes for lvm_vg_open() and internal vg_read()
Message-ID: <1290488470-21743-1-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update some errno values for lvm_vg_open() and vg_read() calls.
I looked through the errno codes and the attached patch was the best
fit I could find for the different error paths in _vg_lock_and_read().

Addresses http://www.redhat.com/archives/linux-lvm/2010-November/msg00081.html


