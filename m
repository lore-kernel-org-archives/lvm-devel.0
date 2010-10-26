From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 26 Oct 2010 14:37:43 +0100
Subject: [PATCH 4/5] Fix theoretical usage of NULL pointer dereference
In-Reply-To: <a1cfd7e4e519a821b545e3a299eb01866ed76877.1288097372.git.zkabelac@redhat.com>
References: <cover.1288097372.git.zkabelac@redhat.com>
	<a1cfd7e4e519a821b545e3a299eb01866ed76877.1288097372.git.zkabelac@redhat.com>
Message-ID: <20101026133743.GI29400@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 26, 2010 at 02:59:25PM +0200, Zdenek Kabelac wrote:
> @@ -97,6 +97,12 @@ int ttree_insert(struct ttree *tt, unsigned int *key, void *data)

> +	if (!*c) {
> +		log_error(INTERNAL_ERROR "Insert failed.");

What am I missing here?
Isn't that condition you are proposing to add logically impossible to
trigger?!

It's not our job to add code just because a particular static analyser
isn't clever enough to understand the logic.

Nack.

Alasdair


