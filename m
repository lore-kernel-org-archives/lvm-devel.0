From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:21:08 +0000
Subject: [PATCH 20/29] Add test for lv_name not NULL
In-Reply-To: <21bdad389ed809525bc1fc06683b692e363a6402.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<21bdad389ed809525bc1fc06683b692e363a6402.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129212108.GI29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:24AM +0100, Zdenek Kabelac wrote:
> -			} else if (!strncmp(vg_name, vgname, strlen(vgname)) &&
> +			} else if (!strncmp(vg_name, vgname, strlen(vgname)) && lv_name &&
>  				   strlen(vgname) == (size_t) (lv_name - vg_name)) {

Ack

Alasdair


