From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 30 Jun 2010 17:46:24 +0100
Subject: [PATCH] Fix read-only warning for partial volume
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228864C3@USINDEVS02.corp.hds.com>
References: <20100630004903.GM23989@agk-dp.fab.redhat.com>
	<5C30BE7ED8B03E448B2E104602D4848A59228864C3@USINDEVS02.corp.hds.com>
Message-ID: <20100630164624.GP23989@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jun 30, 2010 at 12:25:00PM -0400, Takahiro Yasui wrote:
>   Partial mode. Incomplete volumes will be activated.

log_print("Partial mode. Incomplete logical volumes will be processed.");

Yes, the focus is on LVs not VGs

Or, "Logical volumes that have parts missing may still get processed."
 
As MISSING_PV handling has become default behaviour, what *extra* does
--partial offer?

Alasdair


