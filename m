From: dwysocha@redhat.com <dwysocha@redhat.com>
Date: Wed, 09 Apr 2008 17:51:26 -0400
Subject: [patch 0/1] Update vgsplit to only reject splits involving active LVs.
Message-ID: <20080409215126.971729471@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Prior to this change, a VG with any active LVs would cause vgsplit
to fail.  However there should be no reason we cannot split a VG,
provided the LVs involved in the split are inactive.
    
Fixes bz 252041.

-- 


