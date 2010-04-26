From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 15:10:13 +0100
Subject: [PATCH 05/22] Replicator: add lvm support
In-Reply-To: <e64618ea60a4d950d0483f4f1f959806fb8a86b9.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<e64618ea60a4d950d0483f4f1f959806fb8a86b9.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426141013.GO23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:33PM +0200, Zdenek Kabelac wrote:
> Adding configure.in support for Replicators.
> Adding basic lib lvm support for Replicators.
> Adding flags REPLICATOR and REPLICATOR_LOG.
> Adding segments SEG_REPLICATOR and SEG_REPLICATOR_DEV.
> Adding basic methods for handling replicator metadata.
 
> +++ b/lib/metadata/replicator_manip.c

> +#include <inttypes.h>
> +#include <sys/types.h>
> +#include "libdevmapper.h"
> +#include "lvm-types.h"
> +
> +#include "activate.h"
> +#include "archiver.h"
> +#include "defaults.h"
> +#include "label.h"
> +#include "lib.h"
> +#include "locking.h"
> +#include "lv_alloc.h"
> +#include "lvm-string.h"
> +#include "metadata.h"
> +#include "segtype.h"
> +#include "toolcontext.h"

Please clean up those includes: First one is required to be "lib.h" and then
you'll find several of the others listed are already included!

Alasdair


