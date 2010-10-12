From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 12 Oct 2010 11:28:48 -0400
Subject: [PATCH 07/14] Refactor and add code for (lv) 'mirror_log' get function.
In-Reply-To: <8762x837mp.fsf@twilight.int.mornfall.net.>
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-8-git-send-email-dwysocha@redhat.com>
	<8762x837mp.fsf@twilight.int.mornfall.net.>
Message-ID: <1286897328.24741.0.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-10-11 at 20:29 +0200, Petr Rockai wrote:
> Dave Wysochanski <dwysocha@redhat.com> writes:
> 
> > Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> Reviewed-By: Petr Rockai <prockai@redhat.com>
> 
> > +		name = seg->log_lv->name;
> > +	}
> > +	if (name)
> > +		return dm_pool_strndup(mem, name, strlen(name) + 1);
> > +	return NULL;
> > +}
> strndup & unnecessary temporary again
> 

Fixed.

> > -		if (!seg_is_mirrored(seg) || !seg->log_lv)
> > -			continue;
> > -		return dm_report_field_string(rh, field,
> > -					      (const char **) &seg->log_lv->name);
> > -	}
> > +	name = lv_mirror_log_dup(mem, lv);
> > +	if (name)
> > +		return dm_report_field_string(rh, field, &name);
> >  
> >  	dm_report_field_set_value(field, "", NULL);
> >  	return 1;
> 
> OK. Your other patches use if ((name = ...)) style, maybe use it here as
> well? (Or change the others to use this style instead?)
> 

Done.


