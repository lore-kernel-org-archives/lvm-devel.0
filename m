From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 2 Jun 2010 17:43:49 +0100
Subject: [PATCH] Require partial option in lvchange --refresh for partials LVs.
In-Reply-To: <1275495589-15705-1-git-send-email-mbroz@redhat.com>
References: <1275495589-15705-1-git-send-email-mbroz@redhat.com>
Message-ID: <20100602164349.GA11431@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jun 02, 2010 at 06:19:49PM +0200, Milan Broz wrote:
> We must not refresh LV if some PVs are missing and partial activation
> was not requested.
 
Ack.

lvchange --refresh and lvchange -ay should behave the same as each other.

Alasdair


