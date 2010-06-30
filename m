From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 30 Jun 2010 01:49:03 +0100
Subject: [PATCH] Fix read-only warning for partial volume
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228864C1@USINDEVS02.corp.hds.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228864C1@USINDEVS02.corp.hds.com>
Message-ID: <20100630004903.GM23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 29, 2010 at 08:19:14PM -0400, Takahiro Yasui wrote:
>   Partial mode. Incomplete volume groups will be activated read-only.
 
We should probably replace that with a more-accurate description.

Alasdair


