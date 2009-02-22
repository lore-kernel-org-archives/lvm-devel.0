From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 22 Feb 2009 22:46:49 +0000
Subject: [PATCH 04/12] Move vg_t, lv_t, and pv_t from metadata-exported.h into lvm2.h
In-Reply-To: <1234467041-21522-5-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-2-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-3-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-4-git-send-email-dwysocha@redhat.com>
	<1234467041-21522-5-git-send-email-dwysocha@redhat.com>
Message-ID: <20090222224649.GD15443@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Yes, update this after the file renaming and check it in.
I think the abbreviations are OK like this.

> +struct volume_group;
> +typedef struct volume_group vg_t;
> +
> +struct physical_volume;
> +typedef struct physical_volume pv_t;
> +
> +struct logical_volume;
> +typedef struct logical_volume lv_t;

Alasdair
-- 
agk at redhat.com


