From: Petr Rockai <prockai@redhat.com>
Date: Wed, 14 Apr 2010 13:38:25 +0200
Subject: [PATCH 01/22] Add dm_list_splice() for list join.
In-Reply-To: <d80e727dc920a3a77dc38a43125a2bc1b226a125.1271085009.git.zkabelac@redhat.com>
	(Zdenek Kabelac's message of "Mon, 12 Apr 2010 17:21:29 +0200")
References: <cover.1271085009.git.zkabelac@redhat.com>
	<cover.1271085009.git.zkabelac@redhat.com>
	<d80e727dc920a3a77dc38a43125a2bc1b226a125.1271085009.git.zkabelac@redhat.com>
Message-ID: <87y6gq1cy6.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:
> --- a/libdm/datastruct/list.c
> +++ b/libdm/datastruct/list.c
> @@ -144,3 +144,15 @@ unsigned int dm_list_size(const struct dm_list *head)
>  
>  	return s;
>  }
> +
> +void dm_list_splice(struct dm_list *list, struct dm_list *head)
> +{
> +	struct dm_list *first = list->n;
> +	struct dm_list *last = list->p;
> +	struct dm_list *at = head->n;
> +
> +	first->p = head;
> +	head->n = first;
> +	last->n = at;
> +	at->p = last;
> +}

> --- a/libdm/libdevmapper.h
> +++ b/libdm/libdevmapper.h
> @@ -715,6 +715,11 @@ void dm_list_del(struct dm_list *elem);
>  void dm_list_move(struct dm_list *head, struct dm_list *elem);
>  
>  /*
> + * Join 'list' to 'head'.
> + */
> +void dm_list_splice(struct dm_list *list, struct dm_list *head);
> +
> +/*
>   * Is the list empty?
>   */
>  int dm_list_empty(const struct dm_list *head);

Ack. Please check in.

Yours,
   Petr.


