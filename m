From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon, 31 Aug 2009 08:34:59 +0200
Subject: fix small regression when building --with-clvmd=all
Message-ID: <1251700500-15207-1-git-send-email-fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch avoids to build clvmd if there are no backends and
report to the user that we are disabling clvmd build.

Please apply.

Thanks
Fabio


