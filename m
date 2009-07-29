From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 29 Jul 2009 22:30:59 +0100
Subject: [PATCH 1/3] Formalize pe_start policy as split between .pv_setup and .pv_write.
In-Reply-To: <1248900379-28002-2-git-send-email-snitzer@redhat.com>
References: <1248900379-28002-1-git-send-email-snitzer@redhat.com>
	<1248900379-28002-2-git-send-email-snitzer@redhat.com>
Message-ID: <20090729213059.GH29466@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 29, 2009 at 04:46:17PM -0400, Mike Snitzer wrote:
> Fix issue in _text_pv_setup() where existing pe_start case could have
> the pv->pe_start set to pv->pe_align even though pe_start shouldn't ever
> change.
 
vgconvert and pvcreate have a facility to preserve the existing start
of the on-disk data extents, known as pe_start.
They indicate this by passing the existing value to the pvsetup function
which must preserve it.

This patch avoids one particular case where the value could get
changed incorrectly now that the alignment settings are configurable.

Alasdair


