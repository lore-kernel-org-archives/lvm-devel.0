From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 23 Apr 2010 00:30:01 +0100
Subject: [PATCH] Set appropriate udev flags for reserved LVs
In-Reply-To: <4BD0403D.1070203@redhat.com>
References: <4BD0403D.1070203@redhat.com>
Message-ID: <20100422233001.GA23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 22, 2010 at 02:25:33PM +0200, Peter Rajnoha wrote:
>  lib/activate/dev_manager.c |   75 +++++++++++++++++++++++++++----------------
>  lib/misc/lvm-string.c      |   46 +++++++++++++++++++++++++++
>  lib/misc/lvm-string.h      |    3 ++
>  tools/toollib.c            |   46 ---------------------------
>  4 files changed, 96 insertions(+), 74 deletions(-)

Ack.

Alasdair


