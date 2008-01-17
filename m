From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Thu, 17 Jan 2008 03:38:26 -0500
Subject: [PATCH 2/2] Add a test case for 'vgreduce --removemissing' on stacked mirror
Message-ID: <478F1402.9080800@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add a test script for 'make check'.
(Actually, most of the bugs fixed by the patch "1/2" was detected by
 this script.)

Thanks,
--
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: add-mirror-vgreduce-removemissing-test.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080117/ea05cc35/attachment.ksh>
