From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 14:42:44 +0100
Subject: [PATCH 5/5] Check for NULL pointer
In-Reply-To: <c55e248db9914edda41a5d685539277b1bc486a8.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
	<c55e248db9914edda41a5d685539277b1bc486a8.1288097372.git.zkabelac@redhat.com>
Message-ID: <20101026134244.GJ29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 02:59:26PM +0200, Zdenek Kabelac wrote:
> +			if (!options) {
> +				log_error(INTERNAL_ERROR "Missing options.");
> +				return EINVALID_CMD_LINE;
> +			}

Again - what is the bug here?

options is always non-NULL there surely?

What code path causes that new check to fire?

Nack without a decent explanation in the error message of the *cause* not
the symptom.

Alasdair


