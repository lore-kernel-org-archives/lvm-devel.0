From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 16 Oct 2009 00:18:09 +0100
Subject: [PATCH 2 of 10] LVM: make log_area a list
In-Reply-To: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
References: <200910082118.n98LIaik014287@hydrogen.msp.redhat.com>
Message-ID: <20091015231808.GD16950@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 04:18:36PM -0500, Jon Brassow wrote:
> -	struct alloced_area log_area;	/* Extent used for log */
> +	struct dm_list log_areas;	/* Extents used for logs */
>  	struct dm_list alloced_areas[0];	/* Lists of areas in each stripe */

Rather than storing the log areas differently (in a list) from the other areas
(in an array), I'd prefer them all to be stored the same way.

I.e. In a simple contiguous 2-leg mirror plus mirrored log, you'd get
  leg1 as first item on alloced_areas[0] list,
  leg2 as first item on alloced_areas[1] list,
  log leg1 as first item on log_areas list, 
  log leg2 as second item on log_areas list.

I'd prefer to see:
  leg1 as first item on alloced_areas[0] list,
  leg2 as first item on alloced_areas[1] list,
  log leg1 as first item on log_areas[0] list, 
  log leg2 as first item on log_areas[1] list.
and of course log_areas[0] can be the same as alloced_areas[2].

This should be both simpler (logs are less of a special case and 
like any other area may include more than 1 segment) and more general
(we're asking to allocate several parallel areas, with different lengths
but sorted largest first and with different allocation constraints
applying to some of them).

Alasdair


