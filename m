From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Wed, 11 Aug 2010 09:24:22 +0200
Subject: [PATCH] clvmd init: populate Required-Start/Stop at configure time
Message-ID: <4C625026.1050201@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Based on auto-detection or user requested cluster managers for clvmd,
set appropriate Required-Start and Required-Stop at configure time.

Reorder the checks for user selected cluster managers to match auto
detected ones, to be consistent in the output.

Add special case for qdiskd that?s started after cman/lock_gulmd for
RHEL-4/RHEL-5.

Tested on RHEL-4, 5 and 6 and it seems to work fine. I?d really
appreciate some extra testings tho.

Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: clvmd_init_proper_required_start_stop.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100811/b883a708/attachment.ksh>
