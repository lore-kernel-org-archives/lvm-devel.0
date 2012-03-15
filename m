From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 15 Mar 2012 22:22:26 +0000
Subject: [PATCH] Fix broken --major/--minor (RHBZ 801205)
In-Reply-To: <87ty1psqju.fsf_-_@mornfall.net>
References: <20120306023051.13816.qmail@sourceware.org>
	<87y5r1srcc.fsf@mornfall.net> <87ty1psqju.fsf_-_@mornfall.net>
Message-ID: <20120315222226.GF6774@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Mar 15, 2012 at 06:49:09PM +0100, Peter Rockai wrote:
> Petr Rockai <prockai@redhat.com> writes:
> > These two changes are responsible for RHBZ 801205, since we use
> > arg_int_value on the major/minor _ARG in lvchange/lvcreate etc., but it
> > won't work with groupable options.

Gah.

Two options:

  Have minor_ARG and minor_GROUPED_ARG as separate args (and rename other
  GROUPABLE args) 
  - forces the user to know if they're using grouped args or not
    - that might be good or bad

or

  Fix arg_int_value to recognise a groupable arg
        return (_cmdline.arg_props[a].flags & ARG_GROUPABLE) ? first_grouped_arg_int_value(cmd, a, def) : arg_count(cmd, a) ? cmd->arg_values[a].i_value : def;


> +int32_t first_grouped_arg_int_value(struct cmd_context *cmd, int a, const int32_t def)

The arg might not be set in the first group so it does need to loop.

{
        struct arg_value_group_list *current_group;
        struct arg_values *av;

        dm_list_iterate_items(current_group, &cmd->arg_value_groups)  {
		av = current_group->arg_values;
                if (grouped_arg_count(av, a))
                        return grouped_arg_int_value(av, a, def);
	}

        return def;
}

Alasdair


