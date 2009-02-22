From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 22 Feb 2009 23:00:45 +0000
Subject: [PATCH 05/12] Add lvm_pv_name, lvm_vg_name, and lvm_lv_name accessors.
In-Reply-To: <1234467041-21522-6-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-6-git-send-email-dwysocha@redhat.com>
Message-ID: <20090222230045.GE15443@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Feb 12, 2009 at 02:30:34PM -0500, Dave Wysochanski wrote:
> RFC - liblvm could provide accessor functions such as these along with
> the generic attribute functions.  These specific accessor functions will
> make application code simpler and more readable and may be desired by
> application programmers over the generic attribute functions for single
> attributes.
 
> +/*
> + * PV, VG, and LV object attribute functions.
> + */
> +const char *lvm_pv_name(const pv_t *pv);
> +const char *lvm_vg_name(const vg_t *vg);
> +const char *lvm_lv_name(const lv_t *lv);

Maybe, but let's see how the rest of the interface looks.
There are several ways this could be done, including generating
parts of the interface from templates or using the preprocessor
to offer a clean interface to underlying generic functions.

Alasdair
-- 
agk at redhat.com


