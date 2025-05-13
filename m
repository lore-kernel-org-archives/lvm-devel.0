Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3BE11A304A
	for <lvm-devel@lists.linux.dev>; Tue, 13 May 2025 17:35:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747157717; cv=none; b=O8Z8+5n8DcV9+1zoaI2lKYhurxG1jy6EDDZ5IYiCbfAa2lo+JWEk5364BYnSUj9pOO9Jba2IJepVTz7wM686k73ps13eZarYwU5w7KOv/Lknkw4IBVEHqyANYwWtAkTHdPlZG/1RDFCukOb33OoUGP7PFLjuRb6PDWd2p1mr3YE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747157717; c=relaxed/simple;
	bh=YRl+L1t45ORaCLHyHedoS+UhkUZEea/2qWJb2Dou05g=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 In-Reply-To:Content-Type:Content-Disposition; b=XC+4FY8O8CBAv/J8eYrSDafN1CkVyvQxcjcAMnAIKUMLk4CD+4weMELGvcEOaiTkLqYr6Xcd67JqisbjTz9FEk6ZArItiJYbjq0B9NycslkVqEpUEYYxzrtynbQf7WyEZB2na1uSwuFiaVqMyiZonXBkkSSVhvwKQL/v6ROlwLU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=d5EARQX2; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="d5EARQX2"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1747157714;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=kY/JwBZFCO++yuAUOFj+Z3e59kR4DSnOSpEy3fhNVXc=;
	b=d5EARQX2Mr05Yc3LtLON2glCgJV/mVoIE3Mn8Ipxt08uYhTIVCWvUNuTjlNOQgvIFcrieh
	UMIjXVw74wbafe+8jcdsAsPFIPDP4RKcDxtbcKWPIQvkpAJRX8Bo7DxN3ez3RZ0LBJyRJ7
	9f/O+1+gG+Tt1msH4SFmmLeUovatrJM=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-438-xnVJUGBBMlOR6G3x9v7oOA-1; Tue,
 13 May 2025 13:35:10 -0400
X-MC-Unique: xnVJUGBBMlOR6G3x9v7oOA-1
X-Mimecast-MFC-AGG-ID: xnVJUGBBMlOR6G3x9v7oOA_1747157708
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7697E195DE51;
	Tue, 13 May 2025 17:35:08 +0000 (UTC)
Received: from redhat.com (unknown [10.22.66.28])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id DD27119560A7;
	Tue, 13 May 2025 17:35:06 +0000 (UTC)
Date: Tue, 13 May 2025 12:35:04 -0500
From: David Teigland <teigland@redhat.com>
To: Su Yue <glass.su@suse.com>
Cc: lvm-devel@lists.linux.dev, zkabelac@redhat.com, heming.zhao@suse.com,
	l@damenly.org
Subject: Re: [PATCH 0/4] lvm2: add btrfs support for lvresize
Message-ID: <aCOCyIP1W00f6hh7@redhat.com>
References: <20250513061427.25843-1-glass.su@suse.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <20250513061427.25843-1-glass.su@suse.com>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: xbDCKFMnxTVL7zkXppwvo211p0L_5PZg72IveVDdBDw_1747157708
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, May 13, 2025 at 02:14:23PM +0800, Su Yue wrote:
> Hi,
>   This patchset adds btrfs support for lvresize.
>   I tried to split patches as small as minimal for review but 3rd is still
> complicated for bisecting.
>   The patchset passed shell/lvresize-xfs.sh and shell/lvresize-fs.sh on
> CentOS stream, fedora 42 and archlinux to make sure that other fs resize
> functionalties are not broken by the feature.

Thanks, it looks nice, I've pushed these to the main branch.
Dave

