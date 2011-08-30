From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 30 Aug 2011 16:38:27 +0200
Subject: [PATCH] Move config parsing/prettyprinting infrastructure to libdevmapper
In-Reply-To: <871uw45bnb.fsf@aldalome.int.mornfall.net.>
References: <871uw45bnb.fsf@aldalome.int.mornfall.net.>
Message-ID: <4E5CF5E3.10806@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.8.2011 20:13, Petr Rockai napsal(a):
> Hi,
> 
> this is the first patch towards integrating the new daemon
> infrastructure (and, ultimately, lvmetad) into the build. This patch
> moves the core of the lib/config/config.c functionality into
> libdevmapper, leaving behind the LVM-specific parts of the code
> (convenience wrappers that handle `struct device` and `struct
> cmd_context`, basically).
> 
> In the process, I have pragmatically moved part of the lvm-string.c code
> into libdm-string.c, to avoid duplicating shared helpers. This shouldn't
> be a big deal. As another measure to make the move smoother, I have
> slightly generalised the code to handle config overrides (by allowing a
> cascade of config_trees to exist, and adapting the existing
> find_config_tree* functionality in lib/config/config.c to leverage this
> more generic code).
> 
> As an aside, the existing code for handling multiple configurations
> could be moved over to use this same mechanism, with the added benefit
> of making the implied cascading actually work (currently, cascading only
> works on the level of config sections, i.e. only the list of sections is
> actually cascaded, not the values inside, making it impossible to
> override a specific key through cascading).
> 
> As for checking this in, the consensus seems to be towards cvs add-ing
> the new files and checking this more or less in the form of the below
> diff. The other option is to make a server-side copy of
> lib/config/config.c to libdm/libdm-config.c (I will then check this in
> on top of that, making the diff more useful).
> 
> Also, please try to review this quickly, as it is pretty much a
> powerplant patch, and I would hate to get caught up in a conflict mess
> here (unfortunately, not everything in the patch can be mechanically
> repeated).
> 
> For reference, I have used the following sed script to move over most of
> the code to the new names:
> 
> s,\<struct config_tree\>,struct dm_config_tree,g
> s,\<struct config_node\>,struct dm_config_node,g
> s,\<struct config_value\>,struct dm_config_value,g
> 
> s,\<find_config_str\>,dm_config_find_str,g
> s,\<find_config_int\>,dm_config_find_int,g
> s,\<find_config_node\>,dm_config_find_node,g
> 
> s,\<get_config_str\>,dm_config_get_str,g
> s,\<get_config_uint64\>,dm_config_get_uint64,g
> s,\<get_config_uint32\>,dm_config_get_uint32,g
> 
> s,\<config_parent_name\>,dm_config_parent_name,g
> 
> s,\<CFG_STRING\>,DM_CFG_STRING,g
> s,\<CFG_INT\>,DM_CFG_INT,g
> s,\<CFG_EMPTY_ARRAY\>,DM_CFG_EMPTY_ARRAY,g
> 
> s,\<write_config_node\>,dm_config_write_node,g
> s,\<write_config_file\>,dm_config_write,g
> 
> s,\<clone_config_node_with_mem\>,dm_config_clone_node_with_mem,g
> s,\<clone_config_node\>,dm_config_clone_node,g
> 
> s,\<maybe_config_section\>,dm_config_maybe_section,g
> 
> s,\<struct config_tree_list\>,struct dm_config_tree_list,g
> s,= create_config_tree\>,= dm_config_create,g
> s,\<config_file_changed\>,dm_config_changed,g
> s,\<config_file_timestamp\>,dm_config_timestamp,g
> 
> s,\<build_dm_name\>,dm_build_dm_name,g
> s,\<escape_double_quotes\>,dm_escape_double_quotes,g
> s,\<escaped_len\>,dm_escaped_len,g
> s,\<unescape_colons_and_at_signs\>,dm_unescape_colons_and_at_signs,g
> 


Looks like good direction.

ACK

Zdenek


