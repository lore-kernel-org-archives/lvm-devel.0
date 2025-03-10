Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E92E522FF59
	for <lvm-devel@lists.linux.dev>; Mon, 10 Mar 2025 16:25:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1741623903; cv=none; b=qYp8tljryrdC9OR0F6NIIbQvrQ/ZhU9eOEFo0WHSYBQj0J9ILVJvz3HQMshADjJkKJZmwlGW71UoXDprLqYtFu5NmXITh34cf1BxnKCFguHvFrW823HhyUn9c2Iu2uG8pf5XpztoNV1ZYaiEQE7mxfP+JSVVw5izgztgU53DkJg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1741623903; c=relaxed/simple;
	bh=HVSEWeIeoKa7dapepAoc/a2pQ24AfmyQDbcbArBTX20=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 In-Reply-To:Content-Type:Content-Disposition; b=PCa6gwNsuCrk5oVKdi+ZnoJ6Pb8fFymY6cL/y9KqVgGMtddgkBmmmFAV2/xRX/Ysol56MRArI2WnWvZcAWRePWRaYfU6ZBFksu3eLw7iSc9B0Y5H8gE33BE6/vKCZVPI79aPc8vdq8UKcr4in1qMBFJJ+veksvnu8f7Kzi+QpSI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=bz+OuWrk; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="bz+OuWrk"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1741623900;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=zkeAEzq0uf+3vYeItDOuAgwQkJ1VPh1BwA2f3vOL9ZE=;
	b=bz+OuWrkAkune5ZOSRzuKoypzNggHjVVC2OoFLHnbL3ww1HpjFdOIh540lCJYMNxbgXLYx
	I1bcWpPrjr55SCKoN8RGTCfWZCigW1fy+lnOIB2AbjuVC2QOiTvn4v/NZCOglYCuchimJ1
	FDRbXAX+H6I950P+hawgzJux9uNpNZg=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-641-qQ6_EQptP5GBwCGa39Y2Yw-1; Mon,
 10 Mar 2025 12:24:59 -0400
X-MC-Unique: qQ6_EQptP5GBwCGa39Y2Yw-1
X-Mimecast-MFC-AGG-ID: qQ6_EQptP5GBwCGa39Y2Yw_1741623899
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id CAAA9195609E;
	Mon, 10 Mar 2025 16:24:58 +0000 (UTC)
Received: from redhat.com (unknown [10.22.66.35])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 6FE6918001E9;
	Mon, 10 Mar 2025 16:24:57 +0000 (UTC)
Date: Mon, 10 Mar 2025 11:24:54 -0500
From: David Teigland <teigland@redhat.com>
To: Glass Su <glass.su@suse.com>
Cc: lvm-devel@lists.linux.dev, zkabelac@redhat.com,
	Heming Zhao <heming.zhao@suse.com>
Subject: Re: Request for comments about support btrfs in lvresize
Message-ID: <Z88QTwcyqqn-faz_@redhat.com>
References: <D418C150-C1F3-4067-9B72-65C4542DF19F@suse.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <D418C150-C1F3-4067-9B72-65C4542DF19F@suse.com>
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: 4znEf3k_qjrgOYhYHLxoaWBJMEFnnVPIl61I6Vwn-4c_1741623899
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 10, 2025 at 04:35:54PM +0800, Glass Su wrote:
> Hi
>  I am drafting patches for btrfs support in lvresize command. All things went smoothly until I realized
> multi-devices btrfs handling is a little complicated.

btrfs using multiple devices sounds like an alternative to putting btrfs
on lvm, so is this actually done?

> For one device btrfs, fslastblock * fsblocksize/FSSIZE is the correct value like ext* and xfs
> But for multi-devices btrfs, the two values are whole fs size. The used size of device can be
> known by btrfs-progs or superblock read and parse.

These values are used to calculate fs_last_byte, and that is used:

- by lvextend as a sanity check after the fs resize is done.  So, it could
  be made optional for lvextend.

- by lvreduce to check if the fs has already been sufficiently shrunk, so
  the fs shrink command can be skipped.  Perhaps for btrfs, always require
  the fs shrink command to be run, and always make fs_last_byte large enough
  to do that.

Dave

