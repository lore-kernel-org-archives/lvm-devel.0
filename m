From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 21:34:05 +0000
Subject: [PATCH 27/29] Add standard check for result of lv_info call
In-Reply-To: <ca96fa093553cbe0e0c0e15d5e70d7e49334669f.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<ca96fa093553cbe0e0c0e15d5e70d7e49334669f.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129213405.GK29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:31AM +0100, Zdenek Kabelac wrote:
> Also add log_error message in case info would not be found.
 
Ack.

> +			log_error("Check for existence of mirror log '%s' failed.",

I generally don't use any quotes around names.
Heinz uses \".

> +			log_error("Check for existence of mirror leg '%s' failed.",

Rightly or wrongly, we decided never to use 'leg' in user-visible error messages
or documentation (in favour of 'image').

Alasdair


