From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 19 Aug 2010 16:02:55 +0100
Subject: [PATCH 07/11] Add implementation for vg_mda_*_get functions.
In-Reply-To: <1282139522-31240-8-git-send-email-dwysocha@redhat.com>
References: <1282139522-31240-1-git-send-email-dwysocha@redhat.com>
	<1282139522-31240-8-git-send-email-dwysocha@redhat.com>
Message-ID: <20100819150255.GT11907@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Aug 18, 2010 at 09:51:58AM -0400, Dave Wysochanski wrote:
> Add 'get' function implementation for vg_mda_count, vg_mda_used_count,
> vg_mda_free, vg_mda_size.  These are read-only properties so the 'set'
> functions are defined to the _not_implemented function.

They look rather similar to each other:)
You might be able to generate some of them from a template.

#define GET_SIMPLE_VG_PROPERTY_FN(...) ...
 
GET_SIMPLE_PROPERTY_FN(vg_mda_free, vg_mda_free(vg))
GET_SIMPLE_PROPERTY_FN(vg_mda_size, SECTOR_SIZE * vg_mda_size(vg))

Alasdair


