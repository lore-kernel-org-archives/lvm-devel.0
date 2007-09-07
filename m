From: Jim Meyering <jim@meyering.net>
Date: Fri, 07 Sep 2007 14:08:35 +0200
Subject: strdup in str_list.c: why strdup rather than e.g., dm_pool_strdup?
Message-ID: <87sl5q3cfw.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I noticed the use of strdup in str_list.c, and wondered why that code
isn't using dm_pool_strdup, since the list structure itself is allocated
via dm_pool_alloc(mem,...

Anyone know why?

int str_list_dup(struct dm_pool *mem, struct list *sllnew,
		 const struct list *sllold)
{
	struct str_list *sl;

	list_init(sllnew);

	list_iterate_items(sl, sllold) {
		if (!str_list_add(mem, sllnew, strdup(sl->str))) {
[[ why strdup here, and not "dm_pool_strdup(mem," ? ]]
			stack;
			return 0;
		}
	}

	return 1;
}


