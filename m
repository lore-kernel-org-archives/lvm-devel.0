From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 13 May 2009 23:33:13 -0400
Subject: [PATCH 0/30]: liblvm object property baseline, take2
In-Reply-To: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
References: <1242046903-15133-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1242271993.2568.2.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

FYI - I have these patches rebased to Milan's latest lv / snapshot
counting patches (nice cleanup Milan!).  I won't spam the list but if
anyone wants them just let me know.

The new patches now apply on:
commit dc205333cd46770e5ca1a390a6b8fef1f584939a
Author: Milan Broz <mbroz@redhat.com>
Date:   Wed May 13 21:29:10 2009 +0000

    Check max_lv on only place and force the check only for new volume.




