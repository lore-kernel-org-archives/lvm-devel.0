From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 12 Jan 2009 22:16:01 +0000
Subject: [PATCH 4/11] Add vg_read_error and vg_might_exist.
In-Reply-To: <1231769286-15534-5-git-send-email-prockai@redhat.com>
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231769286-15534-4-git-send-email-prockai@redhat.com>
	<1231769286-15534-5-git-send-email-prockai@redhat.com>
Message-ID: <20090112221601.GM1804@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jan 12, 2009 at 03:07:59PM +0100, Peter Rockai wrote:
> +uint32_t vg_read_error(vg_t *vg) {

{ on new line please.

Again, I suggest using a typedef for the return value.

> +	if (!vg)
> +		return FAILED_ALLOCATION;
> +	if (vg->read_failed & EXISTENCE_CHECK)
> +		return vg->read_failed & ~(EXISTENCE_CHECK | FAILED_NOTFOUND);
> +	return vg->read_failed;
> +}

Let's explain that logic in a description above the function (or in the .h file
where the FAILED* are defined).
- Why are some combinations valid in some parts of the code but not in others?
- Is the EXISTENCE_CHECK part obfuscation that could be done more cleanly?

> +/* Queries on a (possibly error-indicating) VG handle. */
> +uint32_t vg_read_error(vg_t *vg);
> +uint32_t vg_might_exist(vg_t *vg);

Explain what the uint32_t returned means.  (Or use a typedef which should be
self-documenting.)

Alasdair
-- 
agk at redhat.com


