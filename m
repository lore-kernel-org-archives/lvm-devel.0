From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 20 May 2016 12:02:56 +0100
Subject: [PATCH] device: include goto label also for O_NOATIME
In-Reply-To: <20160520043805.GA19157@makrotopia.org>
References: <20160520043805.GA19157@makrotopia.org>
Message-ID: <20160520110256.GB2110@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, May 20, 2016 at 06:38:10AM +0200, Daniel Golle wrote:
> on standard C libraries without O_DIRECT_SUPPORT. Make sure it is

Which library or libraries are leading to this problem and what systems
are still using them and do we know why they still don't support
O_DIRECT?

Alasdair


