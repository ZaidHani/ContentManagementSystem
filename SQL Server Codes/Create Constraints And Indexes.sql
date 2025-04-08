/****** Object:  Index [idx_email_notnull]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_email_notnull] ON [Posting].[Editor]
(
	[Email] ASC
)
WHERE ([Email] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_password_notnull]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_password_notnull] ON [Posting].[Editor]
(
	[PasswordHash] ASC
)
WHERE ([PasswordHash] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [idx_phone_notnull]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [idx_phone_notnull] ON [Posting].[Editor]
(
	[Phone] ASC
)
WHERE ([Phone] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_Post_CreatedAt]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Post_CreatedAt] ON [Posting].[Post]
(
	[CreatedAt] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [IndexFileGroup]
GO
/****** Object:  Index [IX_Post_EditorId]    Script Date: 4/8/2025 11:17:44 AM ******/
CREATE NONCLUSTERED INDEX [IX_Post_EditorId] ON [Posting].[Post]
(
	[EditorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [IndexFileGroup]
GO
ALTER TABLE [Logging].[ActionLog] ADD  CONSTRAINT [DF_DateTimeActoinLog]  DEFAULT (getdate()) FOR [TimeStamp]
GO
ALTER TABLE [Logging].[ErrorLog] ADD  CONSTRAINT [DF_DateTimeErrorLog]  DEFAULT (getdate()) FOR [ErrorTime]
GO
ALTER TABLE [Posting].[Category] ADD  CONSTRAINT [DF_Category_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[Category] ADD  CONSTRAINT [DF_Category_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[Editor] ADD  DEFAULT (NULL) FOR [ManagedBy]
GO
ALTER TABLE [Posting].[Editor] ADD  CONSTRAINT [DF_Editor_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[Editor] ADD  CONSTRAINT [DF_Editor_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[EditorDetails] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[EditorDetails] ADD  DEFAULT ((2)) FOR [CreatedBy]
GO
ALTER TABLE [Posting].[EditorDetails] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[Media] ADD  DEFAULT (newid()) FOR [MediaGUID]
GO
ALTER TABLE [Posting].[Media] ADD  CONSTRAINT [DF_Media_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[Media] ADD  CONSTRAINT [DF_Media_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[MediaType] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[MediaType] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[Permission] ADD  CONSTRAINT [DF_Permission_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[Permission] ADD  CONSTRAINT [DF_Permission_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[Post] ADD  CONSTRAINT [DF_Post_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[Post] ADD  CONSTRAINT [DF_Post_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[PostCategory] ADD  CONSTRAINT [DF_PostCategory_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[PostCategory] ADD  CONSTRAINT [DF_PostCategory_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[PostMedia] ADD  DEFAULT ((1)) FOR [MediaId]
GO
ALTER TABLE [Posting].[PostMedia] ADD  CONSTRAINT [DF_PostMedia_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[PostMedia] ADD  CONSTRAINT [DF_PostMedia_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[PublishStatus] ADD  CONSTRAINT [DF_PublishStatus_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[PublishStatus] ADD  CONSTRAINT [DF_PublishStatus_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[Role] ADD  CONSTRAINT [DF_Role_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[Role] ADD  CONSTRAINT [DF_Role_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[RolePermission] ADD  CONSTRAINT [DF_RolePermission_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[RolePermission] ADD  CONSTRAINT [DF_RolePermission_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Posting].[SubCategory] ADD  CONSTRAINT [DF_SubCategory_CreatedAt]  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [Posting].[SubCategory] ADD  CONSTRAINT [DF_SubCategory_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [Logging].[ActionLog]  WITH CHECK ADD FOREIGN KEY([EditorId])
REFERENCES [Posting].[Editor] ([Id])
GO
ALTER TABLE [Logging].[ErrorLog]  WITH CHECK ADD FOREIGN KEY([EditorId])
REFERENCES [Posting].[Editor] ([Id])
GO
ALTER TABLE [Posting].[Editor]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [Posting].[Role] ([Id])
GO
ALTER TABLE [Posting].[Editor]  WITH CHECK ADD  CONSTRAINT [FKSelfJoinManagedBy] FOREIGN KEY([ManagedBy])
REFERENCES [Posting].[Editor] ([Id])
GO
ALTER TABLE [Posting].[Editor] CHECK CONSTRAINT [FKSelfJoinManagedBy]
GO
ALTER TABLE [Posting].[EditorDetails]  WITH CHECK ADD  CONSTRAINT [FK_EmployeeDetails_Editor] FOREIGN KEY([EditorID])
REFERENCES [Posting].[Editor] ([Id])
GO
ALTER TABLE [Posting].[EditorDetails] CHECK CONSTRAINT [FK_EmployeeDetails_Editor]
GO
ALTER TABLE [Posting].[Media]  WITH CHECK ADD  CONSTRAINT [FK_Media_MediaType] FOREIGN KEY([MediaTypeId])
REFERENCES [Posting].[MediaType] ([Id])
GO
ALTER TABLE [Posting].[Media] CHECK CONSTRAINT [FK_Media_MediaType]
GO
ALTER TABLE [Posting].[Post]  WITH CHECK ADD FOREIGN KEY([EditorId])
REFERENCES [Posting].[Editor] ([Id])
GO
ALTER TABLE [Posting].[Post]  WITH CHECK ADD FOREIGN KEY([PublishStatusId])
REFERENCES [Posting].[PublishStatus] ([Id])
GO
ALTER TABLE [Posting].[PostCategory]  WITH CHECK ADD FOREIGN KEY([PostId])
REFERENCES [Posting].[Post] ([Id])
GO
ALTER TABLE [Posting].[PostCategory]  WITH CHECK ADD  CONSTRAINT [FK__PostCateg__SubCa__0A9D95DB] FOREIGN KEY([SubCategoryId])
REFERENCES [Posting].[SubCategory] ([Id])
GO
ALTER TABLE [Posting].[PostCategory] CHECK CONSTRAINT [FK__PostCateg__SubCa__0A9D95DB]
GO
ALTER TABLE [Posting].[PostMedia]  WITH CHECK ADD  CONSTRAINT [FK__PostMedia__PostI__14E61A24] FOREIGN KEY([PostId])
REFERENCES [Posting].[Post] ([Id])
GO
ALTER TABLE [Posting].[PostMedia] CHECK CONSTRAINT [FK__PostMedia__PostI__14E61A24]
GO
ALTER TABLE [Posting].[PostMedia]  WITH CHECK ADD  CONSTRAINT [FKMediaId] FOREIGN KEY([MediaId])
REFERENCES [Posting].[Media] ([Id])
GO
ALTER TABLE [Posting].[PostMedia] CHECK CONSTRAINT [FKMediaId]
GO
ALTER TABLE [Posting].[RolePermission]  WITH CHECK ADD FOREIGN KEY([PermissionId])
REFERENCES [Posting].[Permission] ([Id])
GO
ALTER TABLE [Posting].[RolePermission]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [Posting].[Role] ([Id])
GO
ALTER TABLE [Posting].[SubCategory]  WITH CHECK ADD FOREIGN KEY([CategoryId])
REFERENCES [Posting].[Category] ([Id])
ON DELETE SET NULL
GO