From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 26 Apr 2010 14:15:13 +0100
Subject: [PATCH 01/22] Add dm_list_splice() for list join.
In-Reply-To: <d80e727dc920a3a77dc38a43125a2bc1b226a125.1271085009.git.zkabelac@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<d80e727dc920a3a77dc38a43125a2bc1b226a125.1271085009.git.zkabelac@redhat.com>
Message-ID: <20100426131513.GJ23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 12, 2010 at 05:21:29PM +0200, Zdenek Kabelac wrote:
> Introduce dm_list_splice to join two lists.

OK, but do please retain the style and conventions of the existing functions.

> +void dm_list_splice(struct dm_list *list, struct dm_list *head)

Based on existing conventions, the code appears to implement:
  dm_list_splice_h(struct dm_list *head, struct dm_list *list)

Try the following (untested) instead:

/*
 * Join two lists together.
 * This moves all the elements of the list 'head1' to the end of the list
 * 'head', leaving 'head1' empty.
 */
void dm_list_splice(struct dm_list *head, struct dm_list *head1)
{
	assert(head->n);
	assert(head1->n);

	head1->p->n = head;
	head1->n->p = head->p;

	head->p->n = head1->n;
	head->p = head1->p;

	dm_list_init(head1);
}

Of if you genuinely require the _h version (i.e. the elements are ordered and
you can't choose to retain 'head1' for the combined list instead of 'head.)

/*
 * Join two lists together.
 * This moves all the elements of the list 'head1' to the front of the list
 * 'head', leaving 'head1' empty.
 */
void dm_list_splice_h(struct dm_list *head, struct dm_list *head1)
{
	assert(head->n);
	assert(head1->n);

	head1->n->p = head;
	head1->p->n = head->n;

	head->n->p = head1->p;
	head->n = head1->n;

	dm_list_init(head1);
}

Alasdair


