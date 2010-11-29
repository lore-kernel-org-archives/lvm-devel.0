From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 22:47:51 +0000
Subject: [PATCH 29/29] Check for NULL pointer
In-Reply-To: <4CEEEB09.5050508@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>
	<4CEEEB09.5050508@redhat.com>
Message-ID: <20101129224750.GT29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Nov 26, 2010 at 12:02:33AM +0100, Zdenek Kabelac wrote:
> +	default:
> +		log_error(INTERNAL_ERROR "Unknown report type.");
> +		return ECMD_FAILED;

It's an enum where we cover every value.  An assertion is frankly
pointless.

I could equally perform my own 'static analysis' and deduce that the
default case there is redundant and delete it:)

Alasdair


