From: dwysocha@redhat.com <dwysocha@redhat.com>
Date: Tue, 08 Apr 2008 18:52:43 -0400
Subject: [patch 0/3] Update vgsplit to take "-n LogicalVolumeName" on the commandline.
Message-ID: <20080408225243.753169956@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow the user to specify either a list of PVs or a single LV name via
"-n LogicalVolumeName".
    
Add vgsplit tests to verify vgsplit with "-n LogicalVolumeName" on the
command line.
    
Update the vgsplit man page to reflect "-n LogicalVolumeName".
    
Multiple LVs and more complex cases not currently handled but could be with
future modification.  See negative tests in t-vgsplit-operation.sh for
some examples.

-- 


