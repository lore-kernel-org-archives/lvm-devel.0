From: Christine Caulfield <ccaulfie@redhat.com>
Date: Mon, 19 Apr 2010 13:51:24 +0100
Subject: [PATCH] Add restart option to clvmd
Message-ID: <4BCC51CC.6070407@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch adds a restart command to clvmd (clvmd -S) that restarts the 
daemon preserving exclusive locks. This will not work if clvmd is 
downgraded because the old clvmd does not understand the -E switches.

Chrissie
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: clvmd-restart.patch
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100419/6c867540/attachment.ksh>
