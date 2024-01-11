Received: from mail-pf1-f177.google.com (mail-pf1-f177.google.com [209.85.210.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF3F9EC0
	for <lvm-devel@lists.linux.dev>; Thu, 11 Jan 2024 03:41:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=purestorage.com
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=purestorage.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=purestorage.com header.i=@purestorage.com header.b="XiFeEUsd"
Received: by mail-pf1-f177.google.com with SMTP id d2e1a72fcca58-6d9ac5bd128so3201541b3a.0
        for <lvm-devel@lists.linux.dev>; Wed, 10 Jan 2024 19:41:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=purestorage.com; s=google2022; t=1704944519; x=1705549319; darn=lists.linux.dev;
        h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
         :date:message-id:reply-to;
        bh=N5JO19vyfWea3BrNkqEcexWhPE+I7WuFH7zJee5nWD0=;
        b=XiFeEUsdQmvvdZ2iEZn8n9S98DIHjnk6G+giR3kX4xtoDnK1J3kP/pKDuN2U7EUkNm
         G+oX32PKFcqirij+ZJX2Eqo2PFKeu1rTn0IOt8y5sWeXvqBcyneSXdXZay2gjhO8Kee/
         8hosiPbzrLRqAuJNi/bkHWCNtgWe0wh1sKZNJ5op+kwqC6qRT0VHnYAzaedAeE60c/KA
         y9EhPJJBF5eHSbwa0Ug1pb9h3aJ0nsszYhZutE439GWOWW8mieOY8l9x3kwzrcxap692
         91Lulys0Yw8kz/mQtMvqJxPYYSwV8ClLTC1ubKIzXlScDpGbA4C7MYqfRcZ58T3KnIA7
         pENQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1704944519; x=1705549319;
        h=to:subject:message-id:date:from:mime-version:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=N5JO19vyfWea3BrNkqEcexWhPE+I7WuFH7zJee5nWD0=;
        b=Cguic6wKVhQ8t2/ZntU+3YXNK32xy1hGxwVz1MTuNTEK5TGGkI530Lcc3VAixa1Xd6
         F7nD5G7RsDJ8XqWhcA4l4xZKg+/ZzmhKkWkorih5WlshJTHW8sBp8UxGIQn7ccg0LTlp
         0jcRZjH38JXTnTVWQKboE30U5GvkmC2zJ5ykelSqlp6hjUL7+pIzpjVtSxQeiPTogdxv
         qJy7yEbtxpgbp2adip2XYiFvFNuJ81TxyDz7y1FDaVpNk+X50rBaVDm5XIHDEBgNfnDO
         zGvkHuZgse3eKa+C70vb4M0Vfq6Lj6XxOSAoXpUxLnSw22M1zIvFXerdZHSgQg9RlOJK
         2hRw==
X-Gm-Message-State: AOJu0YyT7R3e6tq/GS4E0YmOVqkGtXZoIKxwgT/WaAeOoLmifxTzOlff
	7uh4Cvv7h0zaXXrGBUySgk3RnV4uRVwn07RwfAN/PTNYwhESinkH6RqckKOkONY=
X-Google-Smtp-Source: AGHT+IEbvmRSNCwM3+gAZPNXZF/XcUp3mkRnHYrOtQLstof6dOOXU9HNMccAdC3kRzUbzubMqtY/jKBjsDNMuinr3xw=
X-Received: by 2002:a05:6a00:1916:b0:6d9:a5c9:db7c with SMTP id
 y22-20020a056a00191600b006d9a5c9db7cmr645685pfi.53.1704944518651; Wed, 10 Jan
 2024 19:41:58 -0800 (PST)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Thu, 11 Jan 2024 09:11:44 +0530
Message-ID: <CAFe+wq3F1TCe9c6VXXiHFcA2Fys_L6+0Jv8FmDy8aH-0HfsOqw@mail.gmail.com>
Subject: Reg thin pool and discard handling
To: lvm-devel@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

Hi Team,
A very happy new year to you all.

When a thin pool is created it has option to control discard behavior.
Typically the useful ones are either discard_passdown vs no_discard_passdown.

My question is as below:
If the thin pool is in "no_discard_passdown" and later changes to
"discard_passdown", would there be a way to reinitiate discard for
those ranges that was not passed down?

Typically fs sitting on top of the thin lv controls discard ranges and
that was already handled as "no_discard_passdown".
Later if say, the backing storage gets filled up, then how can one
re-initiate discard again to allow it to reach
backing storage?

Thanks for your pointers.

Best regards
