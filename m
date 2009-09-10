From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 10 Sep 2009 16:25:16 +0200
Subject: cmirrord cleanup
Message-ID: <1252592719-7061-1-git-send-email-fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patchset makes cmirrord build again and merge the configure checks
with clvmd.

The only bit I am not very pleased is the new requirement on pkg-config.
This is required to retain the current configure.in format where
checks for features are mixed with checks for libraries required
to build that feature. It makes more difficult to share common bits
in favour of better readability.

Please review.

Thanks
Fabio


