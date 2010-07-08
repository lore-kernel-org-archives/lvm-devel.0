From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 08 Jul 2010 15:04:43 +0200
Subject: [PATCH] clvmd should create its own pid file
Message-ID: <4C35CCEB.4020300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi guys,

as discussed on IRC, clvmd needs to create its own pid file.

Code stolen from cmirrord :)

Fabio
-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: clvmd_pid_file.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100708/9dfc1bd2/attachment.ksh>
