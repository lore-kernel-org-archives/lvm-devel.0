From: Milan Broz <mbroz@redhat.com>
Date: Mon, 14 Feb 2011 19:43:53 +0100
Subject: [PATCH] lv_postorder bug (fails to clear temporary flags)
In-Reply-To: <87y65iv4qg.fsf@twilight.int.mornfall.net.>
References: <87y65iv4qg.fsf@twilight.int.mornfall.net.>
Message-ID: <4D5977E9.9000105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On 02/14/2011 07:41 PM, Petr Rockai wrote:
> Milan discovered that running _lv_postorder twice in a row fails to work
> properly, due to uncleared postorder flags. This patch should fix the
> problem.

ack,

my code now works as expected with this patch.

Milan


