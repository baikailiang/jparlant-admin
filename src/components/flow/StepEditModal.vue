<template>
  <n-modal
    v-model:show="visible"
    :mask-closable="false"
    preset="card"
    title="配置流程步骤"
    style="width: 1200px"
    @after-leave="handleAfterLeave"
  >
    <n-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-placement="top"
      class="step-edit-form"
    >
      <div class="grid grid-cols-12 gap-8">
        <!-- 左侧列：基础逻辑 -->
        <div class="col-span-5 space-y-5 border-r pr-8 border-gray-200">
          <div class="section-title flex items-center">
            <span class="w-1 h-6 bg-gradient-to-b from-primary-500 to-primary-600 rounded-full mr-3"></span>
            核心定义
          </div>

          <n-form-item label="步骤名称" path="name">
            <n-input v-model:value="form.name" placeholder="例如：收集手机号 (必填)" />
          </n-form-item>

          <div class="grid grid-cols-2 gap-4">
            <n-form-item label="步骤类型" path="stepType">
              <n-select
                v-model:value="form.stepType"
                :options="stepTypeOptions"
                placeholder="请选择 (必填)"
                :disabled="true"
              />
            </n-form-item>

            <n-form-item label="所属阶段" path="belongToPhase">
              <n-select
                v-model:value="form.belongToPhase"
                :options="phaseOptions"
                placeholder="请选择 (必填)"
                :disabled="form.stepType === 'COMPLETED'"
              />
            </n-form-item>
          </div>

          <n-form-item label="步骤描述" path="description">
            <n-input
              v-model:value="form.description"
              type="textarea"
              :rows="2"
              placeholder="(可选)"
            />
          </n-form-item>

          <!-- 对话交互：仅交互节点、过渡节点和结束节点显示 -->
          <template v-if="form.stepType === 'INPUT' || form.stepType === 'COMPLETED' || form.stepType === 'TRANSITION'">
            <n-divider />
            <div class="section-title flex justify-between items-center">
              <span>{{ form.stepType === 'TRANSITION' ? '过渡回复' : '对话交互' }}</span>
              <n-form-item :show-feedback="false" :show-label="false" class="m-0">
                <n-space align="center">
                  <span class="text-xs text-gray-500">直接回复给用户</span>
                  <n-switch 
                    v-model:value="form.isDirectReturn" 
                    :checked-value="1" 
                    :unchecked-value="0" 
                  />
                </n-space>
              </n-form-item>
            </div>
            <n-form-item label="执行指令" path="prompt">
              <n-input
                v-model:value="form.prompt"
                type="textarea"
                :rows="5"
                :placeholder="form.stepType === 'TRANSITION' ? '输入 AI 回复的指令内容 (必填)' : '需要 AI 执行的指令 (必填)'"
              />
            </n-form-item>
          </template>


          <!-- 允许跳过：交互节点和执行节点显示 -->
          <template v-if="form.stepType === 'INPUT' || form.stepType === 'ACTION'">
            <div class="flex items-center space-x-8 bg-gray-50 p-3 rounded-lg">
              <n-form-item label="允许跳过" :show-feedback="false">
                <n-switch
                  v-model:value="form.canSkip"
                  :disabled="form.stepType === 'ACTION'"
                />
              </n-form-item>
              <n-form-item v-if="form.canSkip && form.stepType === 'INPUT'" label="跳过时的解释" :show-feedback="false" class="flex-1">
                <n-input v-model:value="form.skipToPrompt" placeholder="用户跳过此步时 AI 的回应" />
              </n-form-item>
            </div>
          </template>
        </div>

        <!-- 右侧列：根据节点类型显示不同内容 -->
        <div class="col-span-7 space-y-6 pl-2">
          
          <!-- [重点修改区域] 逻辑节点配置 (ACTION) -->
          <template v-if="form.stepType === 'ACTION'">
            <div class="config-section action-config">
              <div class="flex items-center justify-between mb-4">
                <div>
                  <div class="section-title flex items-center">
                    业务动作配置
                    <n-badge value="必填" type="error" class="ml-2" />
                    <n-tooltip trigger="hover">
                      <template #trigger>
                        <n-icon size="18" class="ml-1 text-gray-400 cursor-help">
                          <svg viewBox="0 0 24 24"><path fill="currentColor" d="M11 18h2v-2h-2v2m1-16A10 10 0 0 0 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2m0 18a8 8 0 0 1-8-8a8 8 0 0 1 8-8a8 8 0 0 1 8 8a8 8 0 0 1-8 8m0-14a4 4 0 0 0-4 4h2a2 2 0 0 1 2-2a2 2 0 0 1 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5a4 4 0 0 0-4-4Z"/></svg>
                        </n-icon>
                      </template>
                      执行后台业务代码逻辑。例如：调用接口查询额度、修改数据库状态、发送通知等。
                    </n-tooltip>
                  </div>
                  <div class="text-xs text-gray-400">动作将按照添加顺序串行执行</div>
                </div>
                <n-button type="primary" secondary size="small" @click="addCoreAction" :disabled="!metadataConfigured">
                   添加执行动作
                </n-button>
              </div>

              <!-- 服务地址未配置提示 -->
              <n-alert v-if="!metadataConfigured" type="warning" class="mb-4">
                <template #header>
                  <span class="font-bold">需要配置业务处理器服务地址</span>
                </template>
                <div class="mt-1">
                  业务动作配置需要连接到业务处理器服务获取可用的处理器列表。
                  <n-button text type="primary" @click="openMetadataConfigModal" class="ml-1">
                    点击此处配置服务地址
                  </n-button>
                </div>
              </n-alert>

              <!-- 已配置时显示当前服务地址 -->
              <div v-else class="flex items-center justify-between mb-4 px-3 py-2 bg-blue-50 rounded-lg border border-blue-200">
                <div class="flex items-center text-sm text-blue-700">
                  <n-icon size="16" class="mr-2">
                    <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2m-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8z"/></svg>
                  </n-icon>
                  <span>服务地址：{{ getMetadataApiUrl() }}</span>
                </div>
                <n-button text type="primary" size="small" @click="openMetadataConfigModal">
                  修改配置
                </n-button>
              </div>

              <div class="space-y-6">
                <div v-for="(action, actionIndex) in coreActions" :key="actionIndex" class="action-card border rounded-xl overflow-hidden shadow-sm">
                  <!-- 卡片头部 -->
                  <div class="bg-gray-100 px-4 py-2 flex items-center justify-between border-b">
                    <div class="flex items-center space-x-2">
                       <n-badge :value="actionIndex + 1" color="#18a058" />
                       <span class="font-bold text-gray-700">业务处理单元</span>
                    </div>
                    <n-button size="tiny" quaternary type="error" @click="removeCoreAction(actionIndex)">移除</n-button>
                  </div>

                  <div class="p-4 space-y-5 bg-white">
                    <!-- 第一步：定位处理器 -->
                    <div class="step-box">
                      <div class="step-header">
                        <div class="step-num">1</div>
                        <div class="step-title">选择处理器</div>
                      </div>
                      <div class="pl-7 mt-2 space-y-3">
                        <div class="grid grid-cols-2 gap-3">
                          <div>
                            <div class="text-xs text-gray-500 mb-1">业务模块</div>
                            <n-select
                              v-model:value="action._selectedBean"
                              :options="beanOptions"
                              placeholder="请选择业务模块"
                              :loading="loadingActionMetadata"
                              filterable
                              @update:value="(val) => handleBeanChange(actionIndex, val)"
                            />
                          </div>
                          <div>
                            <div class="text-xs text-gray-500 mb-1">功能方法</div>
                            <n-select
                              v-model:value="action._selectedMethod"
                              :options="getMethodOptions(action._selectedBean)"
                              placeholder="请先选择模块"
                              :disabled="!action._selectedBean"
                              filterable
                              @update:value="(val) => handleMethodChange(actionIndex, val)"
                            />
                          </div>
                        </div>
                      </div>
                    </div>

                    <!-- 第二步：入参组装 (仅当选择了方法后显示) -->
                    <div v-if="action._methodMetadata" class="step-box">
                      <div class="step-header">
                        <div class="step-num">2</div>
                        <div class="step-title">入参配置</div>
                      </div>
                      <div class="pl-7 mt-2 space-y-2">
                        <div v-if="action._inputMappingArray.length === 0" class="text-center py-4 bg-gray-50 rounded border border-gray-200">
                           <span class="text-gray-400 text-sm">该方法无需输入参数</span>
                        </div>
                        <div v-else class="param-tree-container border rounded-lg overflow-hidden">
                          <div class="bg-gray-50 px-3 py-2 border-b text-xs text-gray-500 grid grid-cols-12 gap-2 items-center">
                            <div class="col-span-4">参数</div>
                            <div class="col-span-2 flex justify-center">类型</div>
                            <div class="col-span-2 flex justify-center">填充模式</div>
                            <div class="col-span-4 flex justify-center">值配置</div>
                          </div>
                          <div v-for="(mapping, mapIndex) in action._inputMappingArray" :key="mapping.id"
                               class="px-3 py-2 border-b last:border-b-0 grid grid-cols-12 gap-2 items-center hover:bg-gray-50"
                               :class="{ 'bg-blue-50/30': mapping.isListItem, 'bg-amber-50/30': mapping.isParent && mapping.isExpanded }">
                            <!-- 参数路径 (带缩进和展开/收起控制) -->
                            <div class="col-span-4 flex items-center">
                              <span :style="{ paddingLeft: mapping.depth * 16 + 'px' }" class="font-mono text-sm flex items-center">
                                <!-- 展开/收起按钮 (对象类型) -->
                                <template v-if="mapping.isParent && !isListType(mapping.schema.type)">
                                  <n-button size="tiny" quaternary circle class="mr-1" @click.stop="toggleObjectExpand(actionIndex, mapping.id)">
                                    <template #icon>
                                      <n-icon size="14" :class="mapping.isExpanded ? 'rotate-90' : ''">
                                        <svg viewBox="0 0 24 24"><path fill="currentColor" d="M8.59 16.59L13.17 12L8.59 7.41L10 6l6 6l-6 6l-1.41-1.41z"/></svg>
                                      </n-icon>
                                    </template>
                                  </n-button>
                                </template>
                                <!-- 集合类型图标 -->
                                <template v-else-if="isListType(mapping.schema.type) && !mapping.isListItem">
                                  <n-icon size="14" class="mr-1 text-blue-500">
                                    <svg viewBox="0 0 24 24"><path fill="currentColor" d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/></svg>
                                  </n-icon>
                                </template>
                                <!-- 子属性缩进线 -->
                                <span v-else-if="mapping.depth > 0 && !mapping.isListItem" class="text-gray-300 mr-1">└─</span>
                                <!-- 集合项标记 -->
                                <span v-else-if="mapping.isListItem" class="text-blue-400 mr-1">├─</span>
                                <!-- 参数名 -->
                                <n-tooltip v-if="mapping.schema.description" trigger="hover">
                                  <template #trigger>
                                    <span class="cursor-help border-b border-dashed border-gray-400">{{ mapping.schema.name }}</span>
                                  </template>
                                  {{ mapping.schema.description }}
                                </n-tooltip>
                                <span v-else>{{ mapping.schema.name }}</span>
                                <!-- 集合项删除按钮 -->
                                <n-button v-if="mapping.isListItem" size="tiny" quaternary circle type="error" class="ml-1" @click.stop="removeListItem(actionIndex, mapping.id)">
                                  <template #icon>
                                    <n-icon size="12"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41Z"/></svg></n-icon>
                                  </template>
                                </n-button>
                              </span>
                            </div>
                            <!-- 类型 -->
                            <!-- 修改类型列：增加居中和 Tooltip -->
                            <div class="col-span-2 flex justify-center overflow-hidden">
                              <n-tooltip trigger="hover">
                                <template #trigger>
                                  <n-tag 
                                    size="tiny" 
                                    :type="mapping.schema.complex ? 'warning' : isListType(mapping.schema.type) ? 'info' : 'success'"
                                    class="max-w-full cursor-help"
                                  >
                                    <!-- 增加 truncate 类确保文字过长时显示省略号 -->
                                    <span class="truncate">{{ mapping.schema.type }}</span>
                                  </n-tag>
                                </template>
                                {{ mapping.schema.type }}
                              </n-tooltip>
                            </div>
                            <!-- 填充模式 -->
                            <div class="col-span-2 flex justify-center items-center">
                              <template v-if="!mapping.isParent || (!mapping.isExpanded && !isListType(mapping.schema.type))">
                                <!-- 内部的 n-select 保持宽度或自适应 -->
                                <n-select
                                  v-model:value="mapping.sourceType"
                                  :options="mapping.isParent ? [{ label: '变量', value: 'context' }] : [{ label: '变量', value: 'context' }, { label: '常量', value: 'constant' }]"
                                  size="tiny"
                                  style="width: 80px"
                                  :disabled="mapping.isExpanded"
                                />
                              </template>
                              <!-- 已展开的对象 -->
                              <template v-else-if="mapping.isExpanded && !isListType(mapping.schema.type)">
                                <span class="text-xs text-amber-600">已展开</span>
                              </template>
                              <!-- 集合类型：显示变量/手动选择 -->
                              <template v-else-if="isListType(mapping.schema.type) && !mapping.isListItem">
                                <n-select
                                  v-model:value="mapping.sourceType"
                                  :options="[{ label: '变量', value: 'context' }, { label: '手动', value: 'manual' }]"
                                  size="tiny"
                                  style="width: 80px"
                                />
                              </template>
                              <template v-else>
                                <span class="text-gray-400 text-xs">-</span>
                              </template>
                            </div>
                            <!-- 值配置 -->
                            <div class="col-span-4 flex justify-center items-center">
                              <!-- 基础类型或整体赋值模式 -->
                              <template v-if="!mapping.isExpanded && mapping.sourceType !== 'expand' && !isListType(mapping.schema.type)">
                                <!-- 变量模式 -->
                                <div v-if="mapping.sourceType === 'context'" class="flex gap-1 items-center w-full justify-center">
                                  <n-tree-select
                                    v-model:value="mapping.value"
                                    :options="actionVariableOptions"
                                    :render-label="renderActionVariableLabel"
                                    placeholder="搜索并选择变量属性..."
                                    size="tiny"
                                    filterable
                                    clearable
                                    class="flex-1"
                                    :class="{ 'type-warning': mapping.value && !checkTypeMatch(mapping.schema.type, mapping.value) }"
                                    default-expand-all
                                  />
                                  <n-tooltip v-if="mapping.value && !checkTypeMatch(mapping.schema.type, mapping.value)" trigger="hover">
                                    <template #trigger>
                                      <n-icon size="16" color="#f0a020"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 4v4h2v-4h-2zm0 6v2h2v-2h-2z"/></svg></n-icon>
                                    </template>
                                    类型可能不匹配：期望 {{ mapping.schema.type }}
                                  </n-tooltip>
                                  <!-- 对象类型可以选择展开 -->
                                  <n-tooltip v-if="mapping.isParent && !isListType(mapping.schema.type)" trigger="hover">
                                    <template #trigger>
                                      <n-button size="tiny" quaternary type="primary" @click.stop="toggleObjectExpand(actionIndex, mapping.id)">
                                        展开
                                      </n-button>
                                    </template>
                                    展开子属性单独配置
                                  </n-tooltip>
                                </div>
                                <!-- 常量模式 -->
                                <template v-else-if="mapping.sourceType === 'constant'">
                                  <n-switch v-if="mapping.schema.type.toLowerCase() === 'boolean'" v-model:value="mapping.value" size="small" />
                                  <n-input-number v-else-if="['integer', 'long', 'double', 'number', 'int', 'float'].includes(mapping.schema.type.toLowerCase())"
                                    v-model:value="mapping.value" size="tiny" :show-button="false" placeholder="输入数值" style="width: 100%" />
                                  <n-input v-else v-model:value="mapping.value" size="tiny" placeholder="输入常量值" />
                                </template>
                              </template>
                              <!-- 已展开：显示收起按钮 -->
                              <template v-else-if="mapping.isExpanded && !isListType(mapping.schema.type)">
                                <n-button size="tiny" quaternary @click.stop="toggleObjectExpand(actionIndex, mapping.id)">
                                  <n-icon size="14" class="mr-1"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6l-6-6l1.41-1.41z"/></svg></n-icon>
                                  收起并整体赋值
                                </n-button>
                              </template>
                              <!-- 集合类型：根据填充模式显示不同内容 -->
                              <template v-else-if="isListType(mapping.schema.type) && !mapping.isListItem">
                                <!-- 变量模式：显示下拉框 -->
                                <div v-if="mapping.sourceType === 'context'" class="flex gap-1 items-center w-full justify-center">
                                  <n-select
                                    v-model:value="mapping.value"
                                    :options="variableOptionsWithPrefix"
                                    placeholder="选择变量"
                                    size="tiny"
                                    filterable
                                    clearable
                                    class="flex-1"
                                    :class="{ 'type-warning': mapping.value && !checkTypeMatch(mapping.schema.type, mapping.value) }"
                                  />
                                  <n-tooltip v-if="mapping.value && !checkTypeMatch(mapping.schema.type, mapping.value)" trigger="hover">
                                    <template #trigger>
                                      <n-icon size="16" color="#f0a020"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 4v4h2v-4h-2zm0 6v2h2v-2h-2z"/></svg></n-icon>
                                    </template>
                                    类型可能不匹配：期望 {{ mapping.schema.type }}
                                  </n-tooltip>
                                </div>
                                <!-- 手动模式：显示添加项按钮和已有项数 -->
                                <div v-else-if="mapping.sourceType === 'manual'" class="flex gap-2 items-center">
                                  <n-button size="tiny" type="primary" secondary @click.stop="addListItem(actionIndex, mapping.id)">
                                    + 添加项
                                  </n-button>
                                  <span v-if="getListItemCount(actionIndex, mapping.id) > 0" class="text-xs text-gray-500">
                                    ({{ getListItemCount(actionIndex, mapping.id) }} 项)
                                  </span>
                                </div>
                              </template>
                              <template v-else>
                                <span class="text-gray-400 text-xs">配置子属性</span>
                              </template>
                            </div>
                          </div>
                        </div>
                        <div class="flex items-center gap-2 mt-2">
                          <n-button size="tiny" quaternary type="primary" @click="openAddVariableModal">
                            + 新建变量
                          </n-button>
                        </div>
                        <!-- <div class="text-[11px] text-gray-400 mt-1">
                          提示：对象类型参数可以<span class="text-orange-500">整体赋值</span>（使用 OBJECT 类型变量）或<span class="text-orange-500">展开子属性</span>单独配置；集合类型点击"添加项"可添加多个条目。
                        </div> -->
                      </div>
                    </div>

                    <!-- 第三步：结果提取 (仅当选择了方法后显示) -->
                    <div v-if="action._methodMetadata" class="step-box">
                      <div class="step-header">
                        <div class="step-num">3</div>
                        <div class="step-title">结果提取</div>
                      </div>
                      <div class="pl-7 mt-2 space-y-2">
                        <!-- <div class="text-xs text-gray-500 mb-2">点击返回结构中的节点，自动生成 JsonPath 并绑定变量：</div> -->
                        <!-- 返回结构树形预览 -->
                        <div class="return-schema-tree border rounded-lg overflow-hidden">
                          <div class="bg-gray-50 px-3 py-2 border-b text-xs text-gray-500 grid grid-cols-12 gap-2">
                            <div class="col-span-5">返回数据</div>
                            <div class="col-span-2">类型</div>
                            <div class="col-span-5">绑定到变量</div>
                          </div>
                          <template v-for="(item, idx) in flattenReturnSchemas(action._methodMetadata.returnSchema)" :key="idx">
                          <div class="px-3 py-2 border-b last:border-b-0 grid grid-cols-12 gap-2 items-center hover:bg-blue-50 cursor-pointer transition-colors"
                               :class="{
                                 'bg-blue-50': getOutputMappingArray(actionIndex).some(m => m.key === item.jsonPath),
                                 'opacity-50 cursor-not-allowed bg-gray-50/50': !isTypeBindable(item.schema) || isOutputPathDisabled(actionIndex, item.jsonPath),
                                 'cursor-pointer': isTypeBindable(item.schema) && !isOutputPathDisabled(actionIndex, item.jsonPath)
                               }"
                               @click="handleOutputRowClick(actionIndex, item.jsonPath, item.schema)">
                            <!-- JsonPath -->
                            <div class="col-span-5 flex items-center">
                              <span :style="{ paddingLeft: item.depth * 16 + 'px' }" class="font-mono text-sm">
                                <span v-if="item.depth > 0" class="text-gray-300 mr-1">└─</span>
                                <n-tooltip v-if="item.schema.description" trigger="hover">
                                  <template #trigger>
                                    <span class="cursor-help border-b border-dashed border-gray-400">{{ item.schema.name }}</span>
                                  </template>
                                  {{ item.schema.description }}
                                </n-tooltip>
                                <span v-else>{{ item.schema.name }}</span>
                              </span>
                            </div>
                            <!-- 类型 -->
                            <div class="col-span-2">
                              <n-tag size="tiny" :type="item.schema.complex ? 'warning' : 'success'">
                                {{ item.schema.type }}
                              </n-tag>
                            </div>
                            <!-- 绑定变量 -->
                            <div class="col-span-5">
                              <!-- 数组类型：已选中，选择目标数组变量 -->
                              <template v-if="isArrayType(item.schema) && getOutputMappingArray(actionIndex).some(m => m.key === item.jsonPath)">
                                <div class="flex gap-1 items-center" @click.stop>
                                  <n-select
                                    :value="getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value || null"
                                    :options="arrayOutputVariableOptions"
                                    placeholder="选择数组变量..."
                                    size="tiny"
                                    filterable
                                    clearable
                                    class="flex-1"
                                    @update:value="(val) => updateArrayOutputTarget(actionIndex, item.jsonPath, val)"
                                  />
                                </div>
                              </template>
                              <!-- 普通类型：已选中 -->
                              <div v-else-if="isTypeBindable(item.schema) && getOutputMappingArray(actionIndex).some(m => m.key === item.jsonPath)" class="flex gap-1 items-center">
                                <n-tree-select
                                  :value="getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value"
                                  :options="outputVariableOptions"
                                  :render-label="renderActionVariableLabel"
                                  placeholder="搜索并选择变量属性..."
                                  size="tiny"
                                  filterable
                                  clearable
                                  class="flex-1"
                                  :class="{ 'type-warning': getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value && !checkTypeMatch(item.schema.type, getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value) }"
                                  default-expand-all
                                  @click.stop
                                  @update:value="(val) => updateOutputMappingValue(actionIndex, item.jsonPath, val)"
                                />
                                <n-tooltip v-if="getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value && !checkTypeMatch(item.schema.type, getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value)" trigger="hover">
                                  <template #trigger>
                                    <n-icon size="16" color="#f0a020"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 4v4h2v-4h-2zm0 6v2h2v-2h-2z"/></svg></n-icon>
                                  </template>
                                  类型可能不匹配：返回类型 {{ item.schema.type }}
                                </n-tooltip>
                              </div>

                              <span v-else-if="!isTypeBindable(item.schema)" class="text-gray-400 text-xs italic">请选择具体属性</span>
                              <span v-else-if="isOutputPathDisabled(actionIndex, item.jsonPath)" class="text-gray-400 text-xs">{{ getOutputDisabledHint(actionIndex, item.jsonPath) }}</span>
                              <span v-else class="text-gray-400 text-xs">点击该行进行绑定</span>
                            </div>
                          </div>
                          <!-- 数组类型 elementMapping：子属性逐行映射 -->
                          <template v-if="isArrayType(item.schema) && getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath && m.value)">
                          <div v-for="(em, emIdx) in getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.elementMapping || []"
                               :key="'em-' + idx + '-' + emIdx"
                               class="px-3 py-2 border-b last:border-b-0 grid grid-cols-12 gap-2 items-center bg-blue-50/30"
                               @click.stop>
                            <!-- 属性名 -->
                            <div class="col-span-5 flex items-center">
                              <span :style="{ paddingLeft: (item.depth + 1) * 16 + 'px' }" class="font-mono text-sm">
                                <span class="text-gray-300 mr-1">└─</span>
                                {{ em.sourceKey.split('.').pop() }}
                              </span>
                            </div>
                            <!-- 类型 -->
                            <div class="col-span-2">
                              <n-tag size="tiny" type="success">
                                {{ em._schemaType || '' }}
                              </n-tag>
                            </div>
                            <!-- 绑定变量 -->
                            <div class="col-span-5">
                              <div class="flex gap-1 items-center">
                                <n-select
                                  :value="em.targetKey"
                                  :options="getArrayElementTargetOptions(getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value)"
                                  placeholder="选择变量属性..."
                                  size="tiny"
                                  filterable
                                  clearable
                                  class="flex-1"
                                  :class="{ 'type-warning': em.targetKey && !checkElementTypeMatch(em._schemaType, em.targetKey, getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value) }"
                                  @update:value="(val) => updateElementMappingTarget(actionIndex, item.jsonPath, em.sourceKey, val)"
                                />
                                <n-tooltip v-if="em.targetKey && !checkElementTypeMatch(em._schemaType, em.targetKey, getOutputMappingArray(actionIndex).find(m => m.key === item.jsonPath)?.value)" trigger="hover">
                                  <template #trigger>
                                    <n-icon size="16" color="#f0a020"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 4v4h2v-4h-2zm0 6v2h2v-2h-2z"/></svg></n-icon>
                                  </template>
                                  类型可能不匹配：源类型 {{ em._schemaType }}
                                </n-tooltip>
                              </div>
                            </div>
                          </div>
                          </template>
                          </template>
                        </div>
                        
                        <div class="flex items-center gap-2 mt-2">
                          <n-button size="tiny" quaternary type="primary" @click="openAddVariableModal">
                            + 新建变量
                          </n-button>
                        </div>
                        
                      </div>
                    </div>

                    <!-- 未选择方法时的提示 -->
                    <div v-if="!action._methodMetadata && action._selectedBean" class="text-center py-6 bg-gray-50 rounded-lg border border-dashed border-gray-300">
                      <n-icon size="32" class="text-gray-300 mb-2"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg></n-icon>
                      <div class="text-gray-400 text-sm">请选择功能方法以配置参数</div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </template>

          <!-- 交互节点配置 -->
          <template v-if="form.stepType === 'INPUT'">
            <!-- 信息提取定义 -->
            <div class="config-section">
              <div class="flex items-center justify-between mb-3">
                <div class="section-title flex items-center">
                  信息提取定义
                  <!-- <n-badge value="必填" type="error" class="ml-2" /> -->
                </div>
              </div>
              <div class="bg-gray-50 p-4 rounded-xl min-h-[80px]">
                <n-form-item :show-label="false" :show-feedback="false" path="selectedVarNames">
                  <div class="flex gap-2 items-start w-full">
                    <n-select
                      v-model:value="form.selectedVarNames"
                      multiple
                      filterable
                      :options="variableOptions"
                      :loading="loadingVars"
                      placeholder="点击选择需要 AI 提取的变量 (支持搜索)..."
                      class="flex-1"
                      @update:value="handleVarChange"
                    />
                    <n-button
                      size="small"
                      quaternary
                      type="primary"
                      @click="openAddVariableModal"
                    >
                      +变量
                    </n-button>
                  </div>
                </n-form-item>
                <div class="text-[10px] text-gray-400 mt-2">
                  提示：选中的变量将作为此步骤的目标，会尝试从用户回答中识别对应信息。
                </div>
              </div>
            </div>

            <!-- 图片识别执行器 -->
            <div class="config-section">
              <div class="flex items-center justify-between mb-3">
                <div class="section-title flex items-center">
                  图片识别执行器
                  <n-tooltip trigger="hover">
                    <template #trigger>
                      <n-icon size="18" class="ml-1 text-gray-400 cursor-help">
                        <svg viewBox="0 0 24 24"><path fill="currentColor" d="M11 18h2v-2h-2v2m1-16A10 10 0 0 0 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2m0 18a8 8 0 0 1-8-8a8 8 0 0 1 8-8a8 8 0 0 1 8 8a8 8 0 0 1-8 8m0-14a4 4 0 0 0-4 4h2a2 2 0 0 1 2-2a2 2 0 0 1 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5a4 4 0 0 0-4-4Z"/></svg>
                      </n-icon>
                    </template>
                    配置用于处理用户上传的图片内容识别后的业务逻辑
                  </n-tooltip>
                </div>
                <n-switch v-model:value="ocrActionEnabled" :disabled="!metadataConfigured" />
              </div>

              <!-- 服务地址未配置提示 -->
              <n-alert v-if="ocrActionEnabled && !metadataConfigured" type="warning" class="mb-3">
                <template #header>
                  <span class="font-bold">需要配置业务功能清单地址</span>
                </template>
                <div class="mt-1">
                  图片识别执行器需要连接到业务功能清单服务获取可用的处理器列表。
                  <n-button text type="primary" @click="openMetadataConfigModal" class="ml-1">
                    点击此处配置服务地址
                  </n-button>
                </div>
              </n-alert>

              <!-- 已配置时显示当前服务地址 -->
              <div v-else-if="ocrActionEnabled" class="flex items-center justify-between mb-4 px-3 py-2 bg-blue-50 rounded-lg border border-blue-200">
                <div class="flex items-center text-sm text-blue-700">
                  <n-icon size="16" class="mr-2">
                    <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2m-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8z"/></svg>
                  </n-icon>
                  <span>服务地址：{{ getMetadataApiUrl() }}</span>
                </div>
                <n-button text type="primary" size="small" @click="openMetadataConfigModal">
                  修改配置
                </n-button>
              </div>

              <div v-if="ocrActionEnabled" class="bg-white p-4 rounded-xl border space-y-4">
                <!-- 第一步：选择处理器 -->
                <div class="step-box">
                  <div class="step-header">
                    <div class="step-num">1</div>
                    <div class="step-title">选择处理器</div>
                  </div>
                  <div class="pl-7 mt-2 space-y-3">
                    <div class="grid grid-cols-2 gap-3">
                      <div>
                        <div class="text-xs text-gray-500 mb-1">业务模块</div>
                        <n-select
                          v-model:value="ocrConfig._selectedBean"
                          :options="beanOptions"
                          placeholder="请选择业务模块"
                          :loading="loadingActionMetadata"
                          filterable
                          @update:value="(val) => handleOcrBeanChange(val)"
                        />
                      </div>
                      <div>
                        <div class="text-xs text-gray-500 mb-1">功能方法</div>
                        <n-select
                          v-model:value="ocrConfig._selectedMethod"
                          :options="getMethodOptions(ocrConfig._selectedBean)"
                          placeholder="请先选择模块"
                          :disabled="!ocrConfig._selectedBean"
                          filterable
                          @update:value="(val) => handleOcrMethodChange(val)"
                        />
                      </div>
                    </div>
                  </div>
                </div>

                <!-- 第二步：结果提取 (仅当选择了方法后显示) -->
                <div v-if="ocrConfig._methodMetadata" class="step-box">
                  <div class="step-header">
                    <div class="step-num">2</div>
                    <div class="step-title">结果提取</div>
                  </div>
                  <div class="pl-7 mt-2 space-y-2">
                    <div class="return-schema-tree border rounded-lg overflow-hidden">
                      <div class="bg-gray-50 px-3 py-2 border-b text-xs text-gray-500 grid grid-cols-12 gap-2">
                        <div class="col-span-5">返回数据</div>
                        <div class="col-span-2">类型</div>
                        <div class="col-span-5">绑定到变量</div>
                      </div>
                      <template v-for="(item, idx) in flattenReturnSchemas(ocrConfig._methodMetadata.returnSchema)" :key="idx">
                      <div class="px-3 py-2 border-b last:border-b-0 grid grid-cols-12 gap-2 items-center hover:bg-blue-50 cursor-pointer transition-colors"
                           :class="{
                             'bg-blue-50': ocrOutputMappingArray.some(m => m.key === item.jsonPath),
                             'opacity-50 cursor-not-allowed bg-gray-50/50': !isTypeBindable(item.schema) || isOcrOutputPathDisabled(item.jsonPath),
                             'cursor-pointer': isTypeBindable(item.schema) && !isOcrOutputPathDisabled(item.jsonPath)
                           }"
                           @click="handleOcrOutputRowClick(item.jsonPath, item.schema)">
                        <!-- JsonPath -->
                        <div class="col-span-5 flex items-center">
                          <span :style="{ paddingLeft: item.depth * 16 + 'px' }" class="font-mono text-sm">
                            <span v-if="item.depth > 0" class="text-gray-300 mr-1">└─</span>
                            <n-tooltip v-if="item.schema.description" trigger="hover">
                              <template #trigger>
                                <span class="cursor-help border-b border-dashed border-gray-400">{{ item.schema.name }}</span>
                              </template>
                              {{ item.schema.description }}
                            </n-tooltip>
                            <span v-else>{{ item.schema.name }}</span>
                          </span>
                        </div>
                        <!-- 类型 -->
                        <div class="col-span-2">
                          <n-tag size="tiny" :type="item.schema.complex ? 'warning' : 'success'">
                            {{ item.schema.type }}
                          </n-tag>
                        </div>
                        <!-- 绑定变量 -->
                        <div class="col-span-5">
                          <!-- 数组类型：已选中，选择目标数组变量 -->
                          <template v-if="isArrayType(item.schema) && ocrOutputMappingArray.some(m => m.key === item.jsonPath)">
                            <div class="flex gap-1 items-center" @click.stop>
                              <n-select
                                :value="ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value || null"
                                :options="arrayOutputVariableOptions"
                                placeholder="选择数组变量..."
                                size="tiny"
                                filterable
                                clearable
                                class="flex-1"
                                @update:value="(val) => updateOcrArrayOutputTarget(item.jsonPath, val)"
                              />
                            </div>
                          </template>
                          <!-- 普通类型：已选中 -->
                          <div v-else-if="isTypeBindable(item.schema) && ocrOutputMappingArray.some(m => m.key === item.jsonPath)" class="flex gap-1 items-center">
                            <n-tree-select
                              :value="ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value"
                              :options="outputVariableOptions"
                              :render-label="renderActionVariableLabel"
                              placeholder="搜索并选择变量属性..."
                              size="tiny"
                              filterable
                              clearable
                              class="flex-1"
                              :class="{ 'type-warning': ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value && !checkTypeMatch(item.schema.type, ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value) }"
                              default-expand-all
                              @click.stop
                              @update:value="(val) => updateOcrOutputMappingValue(item.jsonPath, val)"
                            />
                            <n-tooltip v-if="ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value && !checkTypeMatch(item.schema.type, ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value)" trigger="hover">
                              <template #trigger>
                                <n-icon size="16" color="#f0a020"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 4v4h2v-4h-2zm0 6v2h2v-2h-2z"/></svg></n-icon>
                              </template>
                              类型可能不匹配：返回类型 {{ item.schema.type }}
                            </n-tooltip>
                          </div>

                          <span v-else-if="!isTypeBindable(item.schema)" class="text-gray-400 text-xs italic">请选择具体属性</span>
                          <span v-else-if="isOcrOutputPathDisabled(item.jsonPath)" class="text-gray-400 text-xs">{{ getOcrOutputDisabledHint(item.jsonPath) }}</span>
                          <span v-else class="text-gray-400 text-xs">点击该行绑定变量</span>
                        </div>
                      </div>
                      <!-- 数组类型 elementMapping：子属性逐行映射 -->
                      <template v-if="isArrayType(item.schema) && ocrOutputMappingArray.find(m => m.key === item.jsonPath && m.value)">
                      <div v-for="(em, emIdx) in ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.elementMapping || []"
                           :key="'ocr-em-' + idx + '-' + emIdx"
                           class="px-3 py-2 border-b last:border-b-0 grid grid-cols-12 gap-2 items-center bg-blue-50/30"
                           @click.stop>
                        <!-- 属性名 -->
                        <div class="col-span-5 flex items-center">
                          <span :style="{ paddingLeft: (item.depth + 1) * 16 + 'px' }" class="font-mono text-sm">
                            <span class="text-gray-300 mr-1">└─</span>
                            {{ em.sourceKey.split('.').pop() }}
                          </span>
                        </div>
                        <!-- 类型 -->
                        <div class="col-span-2">
                          <n-tag size="tiny" type="success">
                            {{ em._schemaType || '' }}
                          </n-tag>
                        </div>
                        <!-- 绑定变量 -->
                        <div class="col-span-5">
                          <div class="flex gap-1 items-center">
                            <n-select
                              :value="em.targetKey"
                              :options="getArrayElementTargetOptions(ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value)"
                              placeholder="选择变量属性..."
                              size="tiny"
                              filterable
                              clearable
                              class="flex-1"
                              :class="{ 'type-warning': em.targetKey && !checkElementTypeMatch(em._schemaType, em.targetKey, ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value) }"
                              @update:value="(val) => updateOcrElementMappingTarget(item.jsonPath, em.sourceKey, val)"
                            />
                            <n-tooltip v-if="em.targetKey && !checkElementTypeMatch(em._schemaType, em.targetKey, ocrOutputMappingArray.find(m => m.key === item.jsonPath)?.value)" trigger="hover">
                              <template #trigger>
                                <n-icon size="16" color="#f0a020"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2L1 21h22L12 2zm0 4l7.53 13H4.47L12 6zm-1 4v4h2v-4h-2zm0 6v2h2v-2h-2z"/></svg></n-icon>
                              </template>
                              类型可能不匹配：源类型 {{ em._schemaType }}
                            </n-tooltip>
                          </div>
                        </div>
                      </div>
                      </template>
                      </template>
                    </div>
                    
                    <div class="flex items-center gap-2 mt-2">
                      <n-button size="tiny" quaternary type="primary" @click="openAddVariableModal">
                        + 新建变量
                      </n-button>
                    </div>
                    
                  </div>
                </div>

                <!-- 未选择方法时的提示 -->
                <div v-if="!ocrConfig._methodMetadata && ocrConfig._selectedBean" class="text-center py-6 bg-gray-50 rounded-lg border border-dashed border-gray-300">
                  <n-icon size="32" class="text-gray-300 mb-2"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg></n-icon>
                  <div class="text-gray-400 text-sm">请选择功能方法以配置参数</div>
                </div>
              </div>
            </div>

            <!-- 变量校验规则 -->
            <div class="config-section">
              <div class="flex items-center justify-between mb-3">
                <div class="section-title flex items-center">
                  变量校验规则
                  <!-- <n-badge value="必填" type="error" class="ml-2" /> -->
                </div>
              </div>

              <!-- 必填校验 -->
              <div class="validation-group mb-4">
                <div class="flex items-center justify-between mb-2">
                  <span class="font-medium text-sm">必填校验</span>
                  <n-switch v-model:value="validation.required" />
                </div>
                <div class="text-xs text-gray-500">开启后，<strong>信息提取定义</strong> 中列出的变量若缺失，系统自动报错并引导追问。</div>
              </div>

              <!-- 统一校验规则列表 -->
              <div class="validation-group">
                <div class="flex items-center justify-between mb-3">
                  <span class="font-medium text-sm">校验规则</span>
                  <n-button size="tiny" type="primary" @click="addValidationRule">添加规则</n-button>
                </div>
                

                <div v-if="validation.rules.length === 0" class="text-center py-6 text-gray-400 text-sm bg-white rounded-lg border border-dashed border-gray-200">
                  暂无校验规则，点击上方按钮添加
                </div>
                <div v-else class="space-y-3">
                  <div v-for="(rule, index) in validation.rules" :key="index" class="bg-white p-4 rounded-lg border">
                    <div class="flex items-center justify-between mb-3">
                      <n-tag size="small" :bordered="false" type="primary">规则 {{ index + 1 }}</n-tag>
                      <n-button size="tiny" quaternary type="error" @click="removeValidationRule(index)">删除</n-button>
                    </div>

                    <!-- 路径选择 + 校验类型 -->
                    <div class="grid grid-cols-12 gap-3 mb-3">
                      <div class="col-span-7">
                        <div class="text-xs text-gray-500 mb-1">变量路径</div>
                        <n-tree-select
                          v-model:value="rule.path"
                          :options="variableCascaderOptions"
                          placeholder="选择变量路径"
                          size="small"
                          :show-path="true"
                          clearable
                          default-expand-all
                          :render-label="renderTreeLabel"
                          @update:value="() => handleRulePathChange(index)"
                        />
                      </div>
                      <div class="col-span-5">
                        <div class="text-xs text-gray-500 mb-1">校验类型</div>
                        <n-select
                          v-model:value="rule.ruleType"
                          :options="getRuleTypeOptions(rule.path)"
                          :placeholder="rule.path && getRuleTypeOptions(rule.path).length === 0 ? '该类型不支持校验' : '请先选择路径'"
                          :disabled="!rule.path || getRuleTypeOptions(rule.path).length === 0"
                          size="small"
                        />
                      </div>
                    </div>

                    <!-- 动态配置项：REGEX -->
                    <template v-if="rule.ruleType === 'REGEX'">
                      <div class="grid grid-cols-12 gap-3 mb-3">
                        <div class="col-span-4">
                          <div class="text-xs text-gray-500 mb-1">正则模板</div>
                          <n-select
                            v-model:value="rule._template"
                            :options="regexTemplates"
                            placeholder="选择模板"
                            size="small"
                            clearable
                            @update:value="(val) => applyRuleRegexTemplate(index, val)"
                          />
                        </div>
                        <div class="col-span-8">
                          <div class="text-xs text-gray-500 mb-1">正则表达式</div>
                          <n-input v-model:value="rule.criterion" placeholder="例如: ^\\d{18}$" size="small" />
                        </div>
                      </div>
                    </template>

                    <!-- 动态配置项：LENGTH -->
                    <template v-if="rule.ruleType === 'LENGTH'">
                      <div class="grid grid-cols-12 gap-3 mb-3">
                        <div class="col-span-6">
                          <div class="text-xs text-gray-500 mb-1">最小长度</div>
                          <n-input-number v-model:value="rule.min" placeholder="最小" size="small" :show-button="false" clearable :min="0" :max="rule.max != null ? rule.max : undefined" />
                        </div>
                        <div class="col-span-6">
                          <div class="text-xs text-gray-500 mb-1">最大长度</div>
                          <n-input-number v-model:value="rule.max" placeholder="最大" size="small" :show-button="false" clearable :min="rule.min != null ? rule.min : 0" />
                        </div>
                      </div>
                    </template>

                    <!-- 动态配置项：ENUM -->
                    <template v-if="rule.ruleType === 'ENUM'">
                      <div class="mb-3">
                        <div class="text-xs text-gray-500 mb-1">允许的枚举值</div>
                        <n-select
                          v-model:value="rule.options"
                          multiple
                          tag
                          filterable
                          :show-arrow="false"
                          placeholder="输入选项值后按回车添加"
                          size="small"
                          :options="[]"
                        />
                      </div>
                    </template>

                    <!-- 动态配置项：RANGE -->
                    <template v-if="rule.ruleType === 'RANGE'">
                      <div class="grid grid-cols-12 gap-3 mb-3">
                        <div class="col-span-6">
                          <div class="text-xs text-gray-500 mb-1">最小值</div>
                          <n-input-number v-model:value="rule.min" placeholder="最小值" size="small" :show-button="false" clearable :max="rule.max != null ? rule.max : undefined" />
                        </div>
                        <div class="col-span-6">
                          <div class="text-xs text-gray-500 mb-1">最大值</div>
                          <n-input-number v-model:value="rule.max" placeholder="最大值" size="small" :show-button="false" clearable :min="rule.min != null ? rule.min : undefined" />
                        </div>
                      </div>
                    </template>

                    <!-- 动态配置项：INTEGER -->
                    <template v-if="rule.ruleType === 'INTEGER'">
                      <div class="mb-3 text-xs text-gray-500 bg-gray-50 p-2 rounded">自动校验该数值字段为整数类型</div>
                    </template>

                    <!-- 动态配置项：BOOLEAN_CHECK -->
                    <template v-if="rule.ruleType === 'BOOLEAN_CHECK'">
                      <div class="mb-3 text-xs text-gray-500 bg-gray-50 p-2 rounded">自动校验该字段为合法的布尔值</div>
                    </template>

                    <!-- 动态配置项：COLLECTION_LIMIT -->
                    <template v-if="rule.ruleType === 'COLLECTION_LIMIT'">
                      <div class="grid grid-cols-12 gap-3 mb-3">
                        <div class="col-span-6">
                          <div class="text-xs text-gray-500 mb-1">最少项数</div>
                          <n-input-number v-model:value="rule.minItems" placeholder="最少" size="small" :show-button="false" clearable :min="0" :max="rule.maxItems != null ? rule.maxItems : undefined" />
                        </div>
                        <div class="col-span-6">
                          <div class="text-xs text-gray-500 mb-1">最多项数</div>
                          <n-input-number v-model:value="rule.maxItems" placeholder="最多" size="small" :show-button="false" clearable :min="rule.minItems != null ? rule.minItems : 0" />
                        </div>
                      </div>
                    </template>

                    <!-- 动态配置项：UNIQUE -->
                    <template v-if="rule.ruleType === 'UNIQUE'">
                      <div class="mb-3 text-xs text-gray-500 bg-gray-50 p-2 rounded">自动校验数组元素的唯一性（不允许重复项）</div>
                    </template>

                    <!-- 动态配置项：SPEL -->
                    <template v-if="rule.ruleType === 'SPEL'">
                      <div class="mb-3">
                        <div class="text-xs text-gray-500 mb-1">SpEL 表达式</div>
                        <n-input
                          v-model:value="rule.spelExpression"
                          type="textarea"
                          :rows="2"
                          placeholder="例如: #value > 0 and #value < 100"
                          size="small"
                        />
                      </div>
                    </template>

                    <!-- 错误提示 -->
                    <div>
                      <div class="text-xs text-gray-500 mb-1">错误提示</div>
                      <n-input v-model:value="rule.error" placeholder="校验不通过时的提示信息" size="small" />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </template>

          <!-- 结束节点配置 -->
          <template v-if="form.stepType === 'COMPLETED'">
            <n-alert type="success">结束节点标志着流程的完成。请在"对话交互"中设置结束时的提示语。</n-alert>
          </template>

          <!-- 过渡节点配置 -->
          <template v-if="form.stepType === 'TRANSITION'">
            <n-alert type="info">过渡节点用于在流程中插入 AI 回复，作为步骤间的过渡，无需识别用户输入或执行业务逻辑。</n-alert>
          </template>

          <!-- 注意：分支连线配置已移至画布拖拽连线方式，在此处不再配置 -->
        </div>
      </div>
    </n-form>

    <template #action>
      <n-space justify="end">
        <n-button @click="visible = false">取消</n-button>
        <n-button type="primary" size="large" @click="handleSave" :loading="saving" style="width: 120px">确认保存</n-button>
      </n-space>
    </template>
  </n-modal>

  <!-- 新增变量弹窗 -->
  <n-modal
    v-model:show="showAddVariableModal"
    preset="card"
    title="新增变量"
    style="width: 480px"
    :mask-closable="false"
  >
    <n-form label-placement="top">
      <n-form-item label="变量名称" required>
        <n-input v-model:value="newVariable.name" placeholder="请输入变量名称（英文）" />
      </n-form-item>
      <n-form-item label="变量描述" required>
        <n-input v-model:value="newVariable.description" type="textarea" :rows="2" placeholder="请输入变量描述" />
      </n-form-item>
      <n-form-item label="变量类型" required>
        <n-select v-model:value="newVariable.type" :options="variableTypeOptions" />
      </n-form-item>
    </n-form>
    <template #action>
      <n-space justify="end">
        <n-button @click="showAddVariableModal = false">取消</n-button>
        <n-button type="primary" @click="handleAddVariable" :loading="addingVariable">确认添加</n-button>
      </n-space>
    </template>
  </n-modal>

  <!-- 业务处理器服务地址配置弹窗 -->
  <n-modal
    v-model:show="showMetadataConfigModal"
    preset="card"
    title="配置业务功能清单地址"
    style="width: 500px"
    :mask-closable="false"
  >
    <n-form label-placement="top">
      <n-form-item label="服务地址" required>
        <n-input
          v-model:value="metadataApiUrlInput"
          placeholder="请输入业务功能清单地址，例如：http://192.168.1.100:18700"
        />
      </n-form-item>
      <n-alert type="info" class="mb-4">
        <div>业务功能清单服务用于获取可用的业务模块和功能方法列表。</div>
        <div class="mt-2 text-gray-500">请确保服务地址正确且服务已启动。</div>
      </n-alert>
    </n-form>
    <template #footer>
      <div class="flex justify-end space-x-3">
        <n-button @click="showMetadataConfigModal = false">取消</n-button>
        <n-button type="primary" @click="saveMetadataConfig">保存配置</n-button>
      </div>
    </template>
  </n-modal>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick, h } from 'vue'
import {
  NModal, NForm, NFormItem, NInput, NSelect, NSwitch, NButton, NSpace,
  NIcon, NDivider, NBadge, NTabs, NTabPane, NDynamicTags, NInputNumber,
  NCollapse, NCollapseItem, NAlert, NRadioGroup, NRadioButton, NTreeSelect, useMessage, NTooltip, NTag
} from 'naive-ui'
import { variableApi, stepApi, getMetadataApiUrl, setMetadataApiUrl, isMetadataApiConfigured } from '@/api'
import type { IntentStep, FlowVariable, BeanWithMethods, MethodMetadata, PropertySchema } from '@/types'


// 1. 定义存储多个输入框引用的 Map
const spelManualInputRefs = ref(new Map());

// 2. 设置引用的函数
const setSpelInputRef = (index: number, el: any) => {
  if (el) {
    spelManualInputRefs.value.set(index, el);
  }
};

// 3. 处理变量插入逻辑
const handleSpelVarInsert = (index: number, varName: string) => {
  if (!varName) return;

  const rule = validation.value.businessRules[index];
  const inputComponent = spelManualInputRefs.value.get(index);
  let textarea: HTMLTextAreaElement | null = null;

  if (inputComponent) {
    textarea = inputComponent.$el?.querySelector('textarea') || inputComponent.textareaElRef || null;
  }

  const currentValue = rule.rule || '';
  const insertValue = `#${varName}`;

  if (textarea) {
    const start = textarea.selectionStart || 0;
    const end = textarea.selectionEnd || 0;

    // --- 自动空格逻辑 ---
    let prefix = "";
    if (start > 0) {
      const textBefore = currentValue.substring(0, start);
      if (!textBefore.endsWith("  ")) {
        prefix = textBefore.endsWith(" ") ? " " : "  ";
      }
    }

    let suffix = "";
    if (end < currentValue.length) {
      const textAfter = currentValue.substring(end);
      if (!textAfter.startsWith("  ")) {
        suffix = textAfter.startsWith(" ") ? " " : "  ";
      }
    }

    const finalInsertString = prefix + insertValue + suffix;

    // 更新数据
    rule.rule =
      currentValue.substring(0, start) +
      finalInsertString +
      currentValue.substring(end);

    // 重置光标位置
    nextTick(() => {
      const newPos = start + prefix.length + insertValue.length;
      textarea!.setSelectionRange(newPos, newPos);
      textarea!.focus();
    });
  } else {
    // 兜底逻辑
    const prefix = currentValue.trim().length > 0 ? "  " : "";
    rule.rule = currentValue + prefix + insertValue;
  }
}


// --- 配置项定义 ---
const stepTypeOptions = [
  { label: '交互 (询问信息)', value: 'INPUT' },
  { label: '执行 (后台逻辑)', value: 'ACTION' },
  { label: '过渡 (AI 回复)', value: 'TRANSITION' },
  { label: '完成 (流程结束)', value: 'COMPLETED' }
]

const phaseOptions = [
  { label: '开场引导', value: 'PROLOGUE' },
  { label: '需求挖掘', value: 'UNDERSTANDING' },
  { label: '业务执行', value: 'PROCESSING' },
  { label: '确认复核', value: 'REVIEW' },
  { label: '结束收尾', value: 'CLOSING' }
]

const logicalOperators = [
  { label: '等于 (==)', value: '==' },
  { label: '不等于 (!=)', value: '!=' },
  { label: '大于 (>)', value: '>' },
  { label: '小于 (<)', value: '<' },
  { label: '大于等于 (>=)', value: '>=' },
  { label: '小于等于 (<=)', value: '<=' },
  { label: '文本包含', value: 'contains' },
  { label: '文本不包含', value: 'notContains' }
]

interface Props {
  show: boolean
  step?: IntentStep
  intentId?: number
  allSteps?: IntentStep[]
}

interface Emits {
  (e: 'update:show', value: boolean): void
  (e: 'save', step: IntentStep): void
  (e: 'variable-added'): void
}

const props = defineProps<Props>()
const emits = defineEmits<Emits>()
const message = useMessage()

// --- 变量获取逻辑 ---
const availableVariables = ref<FlowVariable[]>([])
const loadingVars = ref(false)

// --- Action 元数据相关 ---
const actionMetadata = ref<BeanWithMethods[]>([])
const loadingActionMetadata = ref(false)
const showMetadataConfigModal = ref(false)
const metadataApiUrlInput = ref('')
const metadataConfigured = ref(isMetadataApiConfigured())

// 打开配置弹窗
const openMetadataConfigModal = () => {
  metadataApiUrlInput.value = getMetadataApiUrl() || ''
  showMetadataConfigModal.value = true
}

// 保存配置
const saveMetadataConfig = () => {
  const url = metadataApiUrlInput.value.trim()
  if (url) {
    setMetadataApiUrl(url)
    metadataConfigured.value = true
    showMetadataConfigModal.value = false
    // 重新加载元数据
    fetchActionMetadata()
    message.success('服务地址配置成功')
  } else {
    message.warning('请输入有效的服务地址')
  }
}

const fetchActionMetadata = async () => {
  if (!isMetadataApiConfigured()) {
    actionMetadata.value = []
    return
  }
  loadingActionMetadata.value = true
  try {
    const response = await stepApi.getActionMetadata()
    actionMetadata.value = response.data || []
  } catch (error) {
    console.error('加载业务动作元数据失败', error)
    message.error('加载业务处理器失败，请检查服务地址配置是否正确')
  } finally {
    loadingActionMetadata.value = false
  }
}

// 模块选项
const beanOptions = computed(() =>
  actionMetadata.value.map(b => ({
    label: b.displayName || b.beanName,
    value: b.beanName
  }))
)

// 根据选中的 bean 获取方法选项
const getMethodOptions = (beanName: string) => {
  const bean = actionMetadata.value.find(b => b.beanName === beanName)
  if (!bean) return []
  return bean.methods.map(m => ({
    label: m.displayName || m.methodName,
    value: m.methodName
  }))
}

// 获取选中的方法元数据
const getSelectedMethodMetadata = (beanName: string, methodName: string): MethodMetadata | null => {
  const bean = actionMetadata.value.find(b => b.beanName === beanName)
  if (!bean) return null
  return bean.methods.find(m => m.methodName === methodName) || null
}

// 判断是否为集合类型
const isListType = (type: string): boolean => {
  const typeLower = type.toLowerCase()
  return typeLower === 'list' || typeLower === 'array' || typeLower.startsWith('list<') || typeLower.startsWith('arraylist')
}

const isArrayType = (schema: PropertySchema | undefined): boolean => {
  if (!schema) return false
  return isListType(schema.type)
}

const isTypeBindable = (schema: PropertySchema | undefined) => {
  if (!schema) return false;
  if (schema.name === '返回结果(整体)') return false;

  const type = (schema.type || '').toLowerCase();
  // 数组/集合类型允许绑定（走 elementMapping 流程）
  if (isListType(schema.type)) return true;
  const isComplex = schema.complex ||
                    type === 'object' ||
                    (schema.children && schema.children.length > 0);

  return !isComplex;
}

// 判断是否为基础类型
const isSimpleType = (schema: PropertySchema): boolean => {
  if (!schema) return true
  return !schema.complex || (schema.children && schema.children.length === 0)
}

// 检查是否有匹配的完整对象变量（类型匹配）
const hasMatchingObjectVariable = (schemaType: string): boolean => {
  const typeLower = schemaType.toLowerCase()
  return availableVariables.value.some(v => {
    const varTypeLower = v.type.toLowerCase()
    // 对象类型变量可以匹配任何复杂类型
    return varTypeLower === 'object'
  })
}

// 生成入参映射的层级结构（支持对象展开和集合处理）
interface InputMappingItem {
  id: string           // 唯一标识
  path: string         // 参数路径
  schema: PropertySchema
  depth: number        // 显示深度
  sourceType: 'context' | 'constant' | 'expand' | 'manual'  // expand 表示展开子属性, manual 表示手动添加集合项
  value: any           // 值
  isParent: boolean    // 是否是复杂类型的根节点
  isExpanded: boolean  // 是否已展开子属性
  isListItem: boolean  // 是否是集合项
  listIndex?: number   // 集合项索引
  parentId?: string    // 父节点 ID（用于集合项）
}

// 生成唯一 ID
let inputMappingIdCounter = 0
const generateInputMappingId = (): string => {
  return `im_${++inputMappingIdCounter}_${Date.now()}`
}

// 初始化入参映射（仅顶层参数）
const initializeInputMappings = (params: PropertySchema[]): InputMappingItem[] => {
  return params.map(param => ({
    id: generateInputMappingId(),
    path: param.name,
    schema: param,
    depth: 0,
    sourceType: 'context' as const,
    value: '',
    isParent: param.complex && param.children && param.children.length > 0,
    isExpanded: false,
    isListItem: false
  }))
}

// 展开对象的子属性
const expandObjectChildren = (actionIndex: number, itemId: string) => {
  const action = coreActions.value[actionIndex]
  const mappings = action._inputMappingArray as InputMappingItem[]
  const itemIndex = mappings.findIndex(m => m.id === itemId)
  if (itemIndex === -1) return

  const item = mappings[itemIndex]
  if (!item.schema.children || item.schema.children.length === 0) return

  item.isExpanded = true
  item.sourceType = 'expand'

  // 生成子属性映射
  const childMappings: InputMappingItem[] = item.schema.children.map(child => ({
    id: generateInputMappingId(),
    path: `${item.path}.${child.name}`,
    schema: child,
    depth: item.depth + 1,
    sourceType: 'context' as const,
    value: '',
    isParent: child.complex && child.children && child.children.length > 0,
    isExpanded: false,
    isListItem: false,
    parentId: item.id
  }))

  // 插入子属性到当前项后面
  mappings.splice(itemIndex + 1, 0, ...childMappings)
}

// 收起对象的子属性
const collapseObjectChildren = (actionIndex: number, itemId: string) => {
  const action = coreActions.value[actionIndex]
  const mappings = action._inputMappingArray as InputMappingItem[]
  const item = mappings.find(m => m.id === itemId)
  if (!item) return

  item.isExpanded = false
  item.sourceType = 'context'
  item.value = ''

  // 递归收集需要移除的子项 ID
  const collectChildIds = (parentId: string): string[] => {
    const children = mappings.filter(m => m.parentId === parentId)
    let ids: string[] = []
    for (const child of children) {
      ids.push(child.id)
      if (child.isExpanded) {
        ids = ids.concat(collectChildIds(child.id))
      }
    }
    return ids
  }

  const idsToRemove = collectChildIds(itemId)
  action._inputMappingArray = mappings.filter(m => !idsToRemove.includes(m.id))
}

// 切换对象展开/收起状态
const toggleObjectExpand = (actionIndex: number, itemId: string) => {
  const action = coreActions.value[actionIndex]
  const item = (action._inputMappingArray as InputMappingItem[]).find(m => m.id === itemId)
  if (!item) return

  if (item.isExpanded) {
    collapseObjectChildren(actionIndex, itemId)
  } else {
    expandObjectChildren(actionIndex, itemId)
  }
}

// 为集合添加一个新项
const addListItem = (actionIndex: number, itemId: string) => {
  const action = coreActions.value[actionIndex]
  const mappings = action._inputMappingArray as InputMappingItem[]
  const itemIndex = mappings.findIndex(m => m.id === itemId)
  if (itemIndex === -1) return

  const item = mappings[itemIndex]
  if (!isListType(item.schema.type)) return

  // 计算当前集合已有的项数
  const existingItems = mappings.filter(m => m.parentId === item.id && m.isListItem)
  const newIndex = existingItems.length

  // 如果集合元素是复杂类型，创建一个集合项容器
  if (item.schema.children && item.schema.children.length > 0) {
    const listItemId = generateInputMappingId()
    const listItemMapping: InputMappingItem = {
      id: listItemId,
      path: `${item.path}[${newIndex}]`,
      schema: { ...item.schema, name: `[${newIndex}]`, type: '对象' },
      depth: item.depth + 1,
      sourceType: 'expand',
      value: '',
      isParent: true,
      isExpanded: true,
      isListItem: true,
      listIndex: newIndex,
      parentId: item.id
    }

    // 生成集合项的子属性
    const childMappings: InputMappingItem[] = item.schema.children.map(child => ({
      id: generateInputMappingId(),
      path: `${item.path}[${newIndex}].${child.name}`,
      schema: child,
      depth: item.depth + 2,
      sourceType: 'context' as const,
      value: '',
      isParent: child.complex && child.children && child.children.length > 0,
      isExpanded: false,
      isListItem: false,
      parentId: listItemId
    }))

    // 找到最后一个属于该集合的项的位置
    let insertIndex = itemIndex + 1
    for (let i = itemIndex + 1; i < mappings.length; i++) {
      if (mappings[i].parentId === item.id ||
          (mappings[i].parentId && mappings.find(m => m.id === mappings[i].parentId)?.parentId === item.id)) {
        insertIndex = i + 1
      } else {
        break
      }
    }

    mappings.splice(insertIndex, 0, listItemMapping, ...childMappings)

    // 标记集合已展开
    item.isExpanded = true
  } else {
    // 集合元素是基础类型，直接添加一个值项
    const listItemMapping: InputMappingItem = {
      id: generateInputMappingId(),
      path: `${item.path}[${newIndex}]`,
      schema: { name: `[${newIndex}]`, type: 'String', description: '', complex: false, children: [] },
      depth: item.depth + 1,
      sourceType: 'context' as const,
      value: '',
      isParent: false,
      isExpanded: false,
      isListItem: true,
      listIndex: newIndex,
      parentId: item.id
    }

    // 找到插入位置
    let insertIndex = itemIndex + 1
    for (let i = itemIndex + 1; i < mappings.length; i++) {
      if (mappings[i].parentId === item.id) {
        insertIndex = i + 1
      } else {
        break
      }
    }

    mappings.splice(insertIndex, 0, listItemMapping)
  }

  // 标记集合已展开
  item.isExpanded = true
}

// 移除集合项
const removeListItem = (actionIndex: number, itemId: string) => {
  const action = coreActions.value[actionIndex]
  const mappings = action._inputMappingArray as InputMappingItem[]
  const item = mappings.find(m => m.id === itemId)
  if (!item || !item.isListItem) return

  // 递归收集需要移除的子项 ID
  const collectChildIds = (parentId: string): string[] => {
    const children = mappings.filter(m => m.parentId === parentId)
    let ids: string[] = []
    for (const child of children) {
      ids.push(child.id)
      ids = ids.concat(collectChildIds(child.id))
    }
    return ids
  }

  const idsToRemove = [itemId, ...collectChildIds(itemId)]
  action._inputMappingArray = mappings.filter(m => !idsToRemove.includes(m.id))

  // 重新计算剩余集合项的索引
  const parentId = item.parentId
  if (parentId) {
    const remainingItems = action._inputMappingArray.filter(m => m.parentId === parentId && m.isListItem)
    remainingItems.forEach((m, idx) => {
      const oldPath = m.path
      const basePath = oldPath.replace(/\[\d+\]/, '')
      m.listIndex = idx
      m.path = `${basePath}[${idx}]`
      m.schema.name = `[${idx}]`

      // 更新子属性的路径
      const updateChildPaths = (parentId: string, oldBase: string, newBase: string) => {
        action._inputMappingArray.filter(c => c.parentId === parentId).forEach(c => {
          c.path = c.path.replace(oldBase, newBase)
          if (c.isParent || c.isListItem) {
            updateChildPaths(c.id, oldBase, newBase)
          }
        })
      }
      updateChildPaths(m.id, oldPath, m.path)
    })
  }
}

// 获取集合已有的项数
const getListItemCount = (actionIndex: number, itemId: string): number => {
  const action = coreActions.value[actionIndex]
  const mappings = action._inputMappingArray as InputMappingItem[]
  return mappings.filter(m => m.parentId === itemId && m.isListItem).length
}

// 生成出参 JsonPath 的扁平化列表
// 修改为接收数组：flattenReturnSchemas
const flattenReturnSchemas = (schemas: PropertySchema[] | null | undefined, prefix: string = ''): Array<{ jsonPath: string; schema: PropertySchema; depth: number }> => {
  const result: Array<{ jsonPath: string; schema: PropertySchema; depth: number }> = []
  
  if (!schemas || schemas.length === 0) return result

  // 1. 只有在处理最顶层（没有 prefix）时，手动添加一个“完整结果”节点
  if (!prefix) {
    result.push({ 
      jsonPath: '.', 
      schema: { name: '返回结果(整体)', type: 'OBJECT', complex: true, description: '整个接口返回的原始 JSON 对象' } as any, 
      depth: 0 
    })
  }

  // 2. 遍历并列的根属性
  for (const s of schemas) {
    const currentPath = prefix ? `${prefix}.${s.name}` : `$.${s.name}`
    const depth = prefix ? currentPath.split('.').length - 1 : 1 // 根属性深度设为1
    
    result.push({ jsonPath: currentPath, schema: s, depth })

    // 3. 递归处理子属性（ARRAY 类型不递归，其子属性通过 elementMapping 展示）
    if (s.complex && s.children && s.children.length > 0 && !isListType(s.type)) {
      result.push(...flattenReturnSchemas(s.children, currentPath))
    }
  }
  return result
}

// 处理选择 Bean 变化
const handleBeanChange = (actionIndex: number, beanName: string) => {
  const action = coreActions.value[actionIndex]
  action._selectedBean = beanName
  action._selectedMethod = ''
  action.targetProcessor = ''
  action._inputMappingArray = []
  action._outputMappingArray = []
  action._methodMetadata = null
}

// 处理选择方法变化
const handleMethodChange = (actionIndex: number, methodName: string) => {
  const action = coreActions.value[actionIndex]
  const beanName = action._selectedBean

  action._selectedMethod = methodName
  action.targetProcessor = `${beanName}.${methodName}`

  const methodMeta = getSelectedMethodMetadata(beanName, methodName)
  action._methodMetadata = methodMeta

  // 根据参数 schema 初始化入参映射（仅顶层参数）
  if (methodMeta) {
    action._inputMappingArray = initializeInputMappings(methodMeta.parameters)
    action._outputMappingArray = []
  }
}


// 递归构建全量路径树（用于 ACTION 入参和结果提取）
const actionVariableOptions = computed(() => {
  const buildTree = (vars: FlowVariable[], parentPath: string): any[] => {
    return vars.map(v => {
      // 构建当前节点的完整路径，起始节点前缀为 $
      const currentPath = parentPath ? `${parentPath}.${v.name}` : `$.${v.name}`;
      const node: any = {
        label: v.name,
        key: currentPath,
        type: v.type,
        description: v.description,
      };

      // 如果有子项，递归构建
      if (v.children && v.children.length > 0) {
        node.children = buildTree(v.children, currentPath);
      }
      return node;
    });
  };
  return buildTree(availableVariables.value, '');
})

// 结果提取专用：OBJECT/ARRAY 有子属性时禁止直接选择，必须选到具体属性
const outputVariableOptions = computed(() => {
  const buildTree = (vars: FlowVariable[], parentPath: string): any[] => {
    return vars.map(v => {
      const currentPath = parentPath ? `${parentPath}.${v.name}` : `$.${v.name}`;
      const hasChildren = v.children && v.children.length > 0;
      const node: any = {
        label: v.name,
        key: currentPath,
        type: v.type,
        description: v.description,
        disabled: (v.type === 'OBJECT' || v.type === 'ARRAY') && hasChildren,
      };
      if (hasChildren) {
        node.children = buildTree(v.children!, currentPath);
      }
      return node;
    });
  };
  return buildTree(availableVariables.value, '');
})

// 数组结果提取专用：只显示 ARRAY 类型的顶层变量
const arrayOutputVariableOptions = computed(() => {
  return availableVariables.value
    .filter(v => v.type === 'ARRAY')
    .map(v => ({
      label: v.name,
      value: `$.${v.name}`,
      type: v.type,
      description: v.description,
    }))
})

// 根据选中的目标数组变量，返回其子属性叶子节点列表供 elementMapping 选择
const getArrayElementTargetOptions = (targetVarPath: string) => {
  if (!targetVarPath) return []
  const varName = targetVarPath.replace(/^\$\./, '')
  const variable = availableVariables.value.find(v => v.name === varName)
  if (!variable || !variable.children) return []
  const buildOptions = (children: FlowVariable[]): any[] => {
    const result: any[] = []
    for (const c of children) {
      if ((c.type === 'OBJECT' || c.type === 'ARRAY') && c.children && c.children.length > 0) {
        result.push(...buildOptions(c.children))
      } else {
        result.push({ label: c.name, value: c.name, type: c.type, description: c.description })
      }
    }
    return result
  }
  return buildOptions(variable.children)
}

// 树选择器的标签渲染函数（只显示名称，悬浮提示类型和描述）
const renderActionVariableLabel = ({ option }: { option: any }) => {
  const tipParts: string[] = []
  if (option.type) tipParts.push(`类型: ${option.type}`)
  if (option.description) tipParts.push(option.description)
  if (tipParts.length > 0) {
    return h(NTooltip, { placement: 'right', delay: 300 }, {
      trigger: () => h('span', { style: 'display: inline-block; width: 100%;' }, option.label),
      default: () => tipParts.join(' | ')
    })
  }
  return h('span', option.label)
}

// 结果提取绑定变量的标签渲染函数（只显示名称，悬浮提示类型和描述）
const renderBindVariableLabel = (option: any) => {
  const name = option.value as string
  const variable = availableVariables.value.find((v: FlowVariable) => v.name === name)
  if (variable) {
    const tipParts: string[] = []
    if (variable.type) tipParts.push(`类型: ${variable.type}`)
    if (variable.description) tipParts.push(variable.description)
    if (tipParts.length > 0) {
      return h(NTooltip, { placement: 'right', delay: 300 }, {
        trigger: () => h('span', { style: 'display: inline-block; width: 100%;' }, name),
        default: () => tipParts.join(' | ')
      })
    }
  }
  return h('span', name)
}


// 检查 elementMapping 中源属性与目标属性的类型是否匹配
const checkElementTypeMatch = (schemaType: string, targetKey: string, targetVarPath: string): boolean => {
  if (!schemaType || !targetKey || !targetVarPath) return true
  const options = getArrayElementTargetOptions(targetVarPath)
  const opt = options.find((o: any) => o.value === targetKey)
  if (!opt || !opt.type) return true
  const sType = String(schemaType).toLowerCase()
  const vType = String(opt.type).toUpperCase()
  const isSchemaNumber = ['integer', 'long', 'double', 'number', 'int', 'float'].some(t => sType.includes(t))
  if (isSchemaNumber) return vType === 'NUMBER'
  if (sType.includes('string') || sType.includes('char')) return vType === 'STRING'
  if (sType.includes('boolean')) return vType === 'BOOLEAN'
  if (sType.includes('list') || sType.includes('array') || sType.includes('[]')) return vType === 'ARRAY'
  return true
}

// 检查类型匹配
const checkTypeMatch = (schemaType: string, variablePath: string): boolean => {
  // 1. 基础防御：如果参数不全，直接返回 true（不显示警告图标），防止崩溃
  if (!variablePath || !schemaType) {
    return true;
  }

  // 2. 获取变量类型
  // 注意：确保 pathTypeMap 已经逻辑正确地计算了路径
  const varType = pathTypeMap.value.get(variablePath);
  
  // 3. 如果找不到变量定义，说明变量树还没加载好，直接跳过
  if (!varType) {
    return true;
  }

  // 4. 使用 String() 强制转换并进行安全调用
  // 这样即使 schemaType 意外是 null，也不会崩溃
  const sType = String(schemaType).toLowerCase();
  const vType = String(varType).toUpperCase(); // 变量定义里通常是大写: STRING, NUMBER...

  // --- 以下是具体的校验逻辑 ---

  // 后端数字类
  const isSchemaNumber = ['integer', 'long', 'double', 'number', 'int', 'float'].some(t => sType.includes(t));
  if (isSchemaNumber) return vType === 'NUMBER';

  // 后端字符串类
  if (sType.includes('string') || sType.includes('char')) return vType === 'STRING';

  // 后端布尔类
  if (sType.includes('boolean')) return vType === 'BOOLEAN';

  // 后端集合类
  if (sType.includes('list') || sType.includes('array') || sType.includes('[]')) return vType === 'ARRAY';

  // 后端对象类 (如果不是基础类型且不是列表，则视为对象)
  const isSchemaObject = !isSchemaNumber && !sType.includes('string') && !sType.includes('boolean') && 
                         !sType.includes('list') && !sType.includes('array');
  if (isSchemaObject) return vType === 'OBJECT';

  return true;
}

const fetchVariables = async () => {
  if (!props.intentId) return
  loadingVars.value = true
  try {
    const response = await variableApi.listByIntent(props.intentId)
    availableVariables.value = response.data || []
  } catch (error) {
    message.error('加载变量列表失败')
  } finally {
    loadingVars.value = false
  }
}

const variableOptions = computed(() =>
  availableVariables.value.map(v => ({
    label: `${v.name} (${v.description || '无描述'})`,
    value: v.name
  }))
)

const variableOptionsWithPrefix = computed(() =>
  availableVariables.value.map(v => ({
    label: `$.${v.name}`,
    value: `$.${v.name}`
  }))
)

const selectedVarOptions = computed(() =>
  (form.value.selectedVarNames || []).map(name => ({ label: name, value: name }))
)

// --- 路径级联选择器与动态校验规则 ---

// 将变量树转为 TreeSelect 选项格式，自动为数组类型生成 [*] 路径
const variableCascaderOptions = computed(() => {
  const buildOptions = (vars: FlowVariable[], parentPath: string, parentIsArray: boolean): any[] => {
    return vars.filter(v => v).map(v => {
      const basePath = parentIsArray ? `${parentPath}[*]` : parentPath
      const currentPath = basePath ? `${basePath}.${v.name}` : `$.${v.name}`
      const option: any = {
        label: `${v.name} (${v.type})`,
        key: currentPath,
        description: v.description || ''
      }
      if ((v.type === 'OBJECT' || v.type === 'ARRAY') && v.children && v.children.length > 0) {
        option.children = buildOptions(v.children, currentPath, v.type === 'ARRAY')
      }
      return option
    })
  }
  const selectedNames = form.value.selectedVarNames || []
  const filtered = availableVariables.value.filter(v => selectedNames.includes(v.name))
  return buildOptions(filtered, '', false)
})

// 树选择下拉项渲染：鼠标悬停显示变量描述
const renderTreeLabel = ({ option }: { option: any }) => {
  if (option.description) {
    return h(NTooltip, { placement: 'right', delay: 300 }, {
      trigger: () => h('span', { style: 'display: inline-block; width: 100%;' }, option.label),
      default: () => option.description
    })
  }
  return h('span', option.label)
}

// 路径 -> 变量类型映射表
const pathTypeMap = computed(() => {
  const map = new Map<string, string>()
  const buildMap = (vars: FlowVariable[], parentPath: string, parentIsArray: boolean) => {
    for (const v of vars) {
      const basePath = parentIsArray ? `${parentPath}[*]` : parentPath
      const currentPath = basePath ? `${basePath}.${v.name}` : `$.${v.name}`
      map.set(currentPath, v.type)
      if ((v.type === 'OBJECT' || v.type === 'ARRAY') && v.children && v.children.length > 0) {
        buildMap(v.children, currentPath, v.type === 'ARRAY')
      }
    }
  }
  buildMap(availableVariables.value, '', false)
  return map
})

// 根据终点数据类型返回可用的校验操作符选项
const getRuleTypeOptions = (path: string) => {
  const type = pathTypeMap.value.get(path) || ''
  switch (type) {
    case 'STRING':
      return [
        { label: '正则表达式', value: 'REGEX' },
        { label: '长度限制', value: 'LENGTH' },
        { label: '枚举值', value: 'ENUM' },
        { label: 'SpEL 表达式', value: 'SPEL' }
      ]
    case 'NUMBER':
      return [
        { label: '数值范围', value: 'RANGE' },
        { label: '整数校验', value: 'INTEGER' },
        { label: 'SpEL 表达式', value: 'SPEL' }
      ]
    case 'BOOLEAN':
      return [
        { label: '布尔值校验', value: 'BOOLEAN_CHECK' },
        { label: 'SpEL 表达式', value: 'SPEL' }
      ]
    case 'ARRAY':
      return [
        { label: '集合长度约束', value: 'COLLECTION_LIMIT' },
        { label: '唯一性校验', value: 'UNIQUE' },
        { label: 'SpEL 表达式', value: 'SPEL' }
      ]
    case 'OBJECT':
      return []
    default:
      return []
  }
}

// 添加校验规则
const addValidationRule = () => {
  validation.value.rules.push({
    path: null,
    ruleType: '',
    _template: '', // UI 绑定
    template: '',  // 数据持久化
    criterion: '',
    spelExpression: '',
    min: undefined,
    max: undefined,
    minItems: undefined,
    maxItems: undefined,
    options: [],
    properties: [],
    error: ''
  })
}

// 删除校验规则
const removeValidationRule = (index: number) => {
  validation.value.rules.splice(index, 1)
}

// 路径变更时重置校验类型
const handleRulePathChange = (index: number) => {
  validation.value.rules[index].ruleType = ''
}

// 应用正则模板到统一规则
const applyRuleRegexTemplate = (index: number, templateValue: string) => {
  const template = regexTemplates.find(t => t.value === templateValue)
  if (template) {
    validation.value.rules[index].criterion = template.pattern
    validation.value.rules[index]._template = templateValue
  }
}

// --- 表单基础状态 ---
const initFormState = () => ({
  intentId: props.intentId,
  name: '',
  description: '',
  stepType: undefined,
  belongToPhase: undefined,
  priority: undefined,
  enabled: true,
  prompt: '',
  ocrPrompt: '',
  canSkip: false,
  skipToPrompt: '',
  expectedInputsJson: '',
  validationJson: '',
  coreActionsJson: '',
  ocrAction: '',
  metadataJson: '',
  isDirectReturn: 0,
  selectedVarNames: [] as string[]
})

const visible = computed({
  get: () => props.show,
  set: (value) => emits('update:show', value)
})

const formRef = ref()
const saving = ref(false)
const form = ref<any>(initFormState())

// --- 校验规则相关 ---
const validation = ref<any>({
  required: true,
  rules: [] as any[]
})

const regexTemplates = [
  { label: '手机号', value: 'mobile', pattern: '^1[3-9]\\d{9}$' },
  { label: '邮箱', value: 'email', pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$' },
  { label: '纯数字', value: 'number', pattern: '^\\d+$' },
  { label: '身份证', value: 'idcard', pattern: '^[1-9]\\d{5}(18|19|20)\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\d|3[01])\\d{3}[0-9Xx]$' },
  { label: '中文字符', value: 'chinese', pattern: '^[\\u4e00-\\u9fa5]+$' }
]

const addRegexRule = () => validation.value.regexRules.push({ field: '', template: '', pattern: '', error: '' })
const removeRegexRule = (index: number) => validation.value.regexRules.splice(index, 1)
const applyRegexTemplate = (index: number, templateValue: string) => {
  const template = regexTemplates.find(t => t.value === templateValue)
  if (template) {
    validation.value.regexRules[index].pattern = template.pattern
    const field = validation.value.regexRules[index].field
    if (field && !validation.value.regexRules[index].error) {
      validation.value.regexRules[index].error = `请输入正确的${field}`
    }
  }
}

const autoGenerateError = (rule: any, type: string) => {
  if (!rule.field || (rule.error && rule.error.trim() !== '')) return
  const labels: any = { regex: '格式', option: '选项', range: '数值', remote: '验证' }
  rule.error = `${rule.field}${labels[type]}不满足要求`
}

const addOptionRule = () => validation.value.optionRules.push({ field: '', options: [], error: '' })
const removeOptionRule = (index: number) => validation.value.optionRules.splice(index, 1)
const addRangeRule = () => validation.value.rangeRules.push({ field: '', min: undefined, max: undefined, error: '' })
const removeRangeRule = (index: number) => validation.value.rangeRules.splice(index, 1)
const addRemoteRule = () => validation.value.remoteRules.push({ field: '', beanName: '', methodName: '', error: '' })
const removeRemoteRule = (index: number) => validation.value.remoteRules.splice(index, 1)
const addBusinessRule = () => validation.value.businessRules.push({ mode: 'visual', tempField: '', tempOperator: '==', targetType: 'value', tempValue: '', rule: '', error: '' })
const removeBusinessRule = (index: number) => validation.value.businessRules.splice(index, 1)

// --- 执行节点配置逻辑 ---
const coreActions = ref<any[]>([])
const addCoreAction = () => coreActions.value.push({
  targetProcessor: '',
  inputMapping: {},
  outputMapping: {},
  _inputMappingArray: [],
  _outputMappingArray: [],
  _selectedBean: '',
  _selectedMethod: '',
  _methodMetadata: null
})
const removeCoreAction = (index: number) => coreActions.value.splice(index, 1)
const getInputMappingArray = (idx: number) => coreActions.value[idx]._inputMappingArray ||= []
const getOutputMappingArray = (idx: number) => coreActions.value[idx]._outputMappingArray ||= []
const addInputMapping = (idx: number) => getInputMappingArray(idx).push({ key: '', sourceType: 'context', value: '' })
const removeInputMapping = (idx: number, midx: number) => getInputMappingArray(idx).splice(midx, 1)
const addOutputMapping = (idx: number) => {
  getOutputMappingArray(idx).push({ key: '$.', value: '' })
}
const removeOutputMapping = (idx: number, midx: number) => getOutputMappingArray(idx).splice(midx, 1)

// 判断 ancestor 是否是 descendant 的祖先路径
const isAncestorPath = (ancestor: string, descendant: string): boolean => {
  if (ancestor === descendant) return false
  if (ancestor === '.') return true
  return descendant.startsWith(ancestor + '.')
}

// 检查业务动作结果提取中某路径是否因父子互斥而被禁用
const isOutputPathDisabled = (actionIndex: number, jsonPath: string): boolean => {
  const outputArr = getOutputMappingArray(actionIndex)
  for (const m of outputArr) {
    if (m.key === jsonPath) continue

    if (m.isArray && isAncestorPath(m.key, jsonPath)) continue 
    
    if (!m.value || !isTypeBindable(m.schema)) continue

    // 如果上级是数组，这里也需要额外判断，不让它禁用下级
    if (isAncestorPath(m.key, jsonPath) && isListType(m.schema?.type || '')) continue
    if (isAncestorPath(m.key, jsonPath) || isAncestorPath(jsonPath, m.key)) return true
  }
  return false
}


// 获取业务动作结果提取中被禁用路径的提示文案
const getOutputDisabledHint = (actionIndex: number, jsonPath: string): string => {
  const outputArr = getOutputMappingArray(actionIndex)
  for (const m of outputArr) {
    if (m.key === jsonPath) continue
    
    if (!m.value || !isTypeBindable(m.schema)) continue

    if (isAncestorPath(m.key, jsonPath) && isListType(m.schema?.type || '')) continue
    if (isAncestorPath(jsonPath, m.key) && isListType(schema?.type || '')) continue // 如果当前是数组也不提示

    if (isAncestorPath(m.key, jsonPath)) return '上级属性已绑定'
    if (isAncestorPath(jsonPath, m.key)) return '子属性已绑定'
  }
  return ''
}

// 处理输出映射行点击
const handleOutputRowClick = (actionIndex: number, jsonPath: string, schema: PropertySchema) => {
  // 核心修改：使用新的判断逻辑
  if (!isTypeBindable(schema)) return; 
  
  if (isOutputPathDisabled(actionIndex, jsonPath)) return;
  toggleOutputMapping(actionIndex, jsonPath, schema);
}

// 递归提取 schema 子属性的叶子节点（用于数组 elementMapping）
const flattenSchemaLeaves = (schemas: PropertySchema[], parentPath: string): Array<{ jsonPath: string; schema: PropertySchema }> => {
  const result: Array<{ jsonPath: string; schema: PropertySchema }> = []
  for (const s of schemas) {
    const currentPath = `${parentPath}.${s.name}`
    if (s.complex && s.children && s.children.length > 0 && !isListType(s.type)) {
      result.push(...flattenSchemaLeaves(s.children, currentPath))
    } else {
      result.push({ jsonPath: currentPath, schema: s })
    }
  }
  return result
}

const toggleOutputMapping = (actionIndex: number, jsonPath: string, schema: PropertySchema) => {
  const outputArr = getOutputMappingArray(actionIndex)
  const existingIndex = outputArr.findIndex((m: any) => m.key === jsonPath)

  if (existingIndex >= 0) {
    // 已存在则移除
    outputArr.splice(existingIndex, 1)
  } else {
    if (isArrayType(schema)) {
      // 数组类型：初始化 elementMapping，但不再要求根路径绑定变量 (value 留空)
      const elementMappings: any[] = []
      if (schema.children && schema.children.length > 0) {
        // 提取叶子节点
        const flatChildren = flattenSchemaLeaves(schema.children, '$')
        flatChildren.forEach(child => {
          elementMappings.push({
            sourceKey: child.jsonPath,
            targetKey: '', // 这里的 targetKey 将映射到全局变量
            _schemaType: child.schema.type
          })
        })
      }
      // 添加到映射表，isArray 为 true 标识这是一个数组展开模式
      outputArr.push({ key: jsonPath, value: '', schema, isArray: true, elementMapping: elementMappings })
    } else {
      // 不存在则添加
      outputArr.push({ key: jsonPath, value: '', schema })
    }

    // 删除所有祖先和后代路径的映射
    const action = coreActions.value[actionIndex]
    action._outputMappingArray = outputArr.filter((m: any) => {
      // 如果涉及到的路径中有任何一个是数组类型，就不执行互斥删除逻辑
      const isRelated = isAncestorPath(jsonPath, m.key) || isAncestorPath(m.key, jsonPath)
      if (isRelated) {
        const isArrayRelated = isListType(schema?.type || '') || isListType(m.schema?.type || '')
        return !isRelated || isArrayRelated // 如果是数组相关的，我们返回 true 保留它
      }
      return true
    })
  }
}

// 更新输出映射的变量绑定
const updateOutputMappingValue = (actionIndex: number, jsonPath: string, value: string) => {
  const outputArr = getOutputMappingArray(actionIndex)
  const mapping = outputArr.find((m: any) => m.key === jsonPath)
  if (mapping) {
    mapping.value = value
  }
}

// 更新数组映射的目标变量
const updateArrayOutputTarget = (actionIndex: number, jsonPath: string, targetVar: string) => {
  const outputArr = getOutputMappingArray(actionIndex)
  const mapping = outputArr.find((m: any) => m.key === jsonPath)
  if (mapping) {
    mapping.value = targetVar
    // 重置所有 elementMapping 的 targetKey
    if (mapping.elementMapping) {
      mapping.elementMapping.forEach((em: any) => { em.targetKey = '' })
    }
  }
}

// 更新 elementMapping 中某一项的目标属性
const updateElementMappingTarget = (actionIndex: number, jsonPath: string, sourceKey: string, targetKey: string) => {
  const outputArr = getOutputMappingArray(actionIndex)
  const mapping = outputArr.find((m: any) => m.key === jsonPath)
  if (mapping && mapping.elementMapping) {
    const em = mapping.elementMapping.find((e: any) => e.sourceKey === sourceKey)
    if (em) em.targetKey = targetKey
  }
}

// ACTION输入参数：选择变量后自动填充参数名（去掉$.前缀）
const handleActionInputVarChange = (actionIdx: number, mapIdx: number, val: string) => {
  const mapping = getInputMappingArray(actionIdx)[mapIdx]
  if (val && val.startsWith('$.')) {
    mapping.key = val.substring(2)
  }
}

// ACTION输出映射：选择变量后自动填充结果属性为$.变量名
const handleActionOutputVarChange = (actionIdx: number, mapIdx: number, val: string) => {
  const mapping = getOutputMappingArray(actionIdx)[mapIdx]
  if (val) {
    // 选中变量时，强制结果属性变为 $.变量名
    mapping.key = `$.${val}`
  }
}

// ACTION输出映射：防止删除$.前缀
const handleActionOutputKeyInput = (actionIdx: number, mapIdx: number, val: string) => {
  const mapping = getOutputMappingArray(actionIdx)[mapIdx]
  
  // 如果输入为空或长度小于2或不以 $. 开头
  if (!val || val.length < 2 || !val.startsWith('$.')) {
    // 提取用户输入的有效后缀（过滤掉杂乱的 $ 或 . 符号）
    const suffix = val.replace(/^\$|^\./g, '')
    // 强制恢复前缀
    mapping.key = '$.' + (suffix.startsWith('$.') ? suffix.substring(2) : suffix)
    return
  }
  
  // 正常输入
  mapping.key = val
}

// --- 图片识别执行器配置逻辑 ---
const ocrActionEnabled = ref(false)
const ocrConfig = ref<any>({ targetProcessor: '', _selectedBean: '', _selectedMethod: '', _methodMetadata: null })
const ocrOutputMappingArray = ref<any[]>([])
const removeOcrOutputMapping = (idx: number) => ocrOutputMappingArray.value.splice(idx, 1)

// 处理 OCR 选择 Bean 变化
const handleOcrBeanChange = (beanName: string) => {
  ocrConfig.value._selectedBean = beanName
  ocrConfig.value._selectedMethod = ''
  ocrConfig.value.targetProcessor = ''
  ocrConfig.value._methodMetadata = null
  ocrOutputMappingArray.value = []
}

// 处理 OCR 选择方法变化
const handleOcrMethodChange = (methodName: string) => {
  const beanName = ocrConfig.value._selectedBean
  ocrConfig.value._selectedMethod = methodName
  ocrConfig.value.targetProcessor = `${beanName}.${methodName}`
  ocrConfig.value._methodMetadata = getSelectedMethodMetadata(beanName, methodName)
  ocrOutputMappingArray.value = []
}

// 检查 OCR 结果提取中某路径是否因父子互斥而被禁用
const isOcrOutputPathDisabled = (jsonPath: string): boolean => {
  for (const m of ocrOutputMappingArray.value) {
    if (m.key === jsonPath) continue

    if (m.isArray && isAncestorPath(m.key, jsonPath)) continue

    if (!m.value || !isTypeBindable(m.schema)) continue

    if (isAncestorPath(m.key, jsonPath) && isListType(m.schema?.type || '')) continue
    if (isAncestorPath(m.key, jsonPath) || isAncestorPath(jsonPath, m.key)) return true
  }
  return false
}

// 获取 OCR 结果提取中被禁用路径的提示文案
const getOcrOutputDisabledHint = (jsonPath: string): string => {
  for (const m of ocrOutputMappingArray.value) {
    if (m.key === jsonPath) continue

    if (!m.value || !isTypeBindable(m.schema)) continue

    if (isAncestorPath(m.key, jsonPath) && isListType(m.schema?.type || '')) continue

    if (isAncestorPath(m.key, jsonPath)) return '上级属性已绑定'
    if (isAncestorPath(jsonPath, m.key)) return '子属性已绑定'
  }
  return ''
}

// 处理 OCR 输出映射行点击
const handleOcrOutputRowClick = (jsonPath: string, schema: PropertySchema) => {
  if (!isTypeBindable(schema)) return;
  if (isOcrOutputPathDisabled(jsonPath)) return
  const existingIndex = ocrOutputMappingArray.value.findIndex((m: any) => m.key === jsonPath)
  if (existingIndex >= 0) {
    ocrOutputMappingArray.value.splice(existingIndex, 1)
  } else {
    if (isArrayType(schema)) {
      const elementMappings: any[] = []
      if (schema.children && schema.children.length > 0) {
        const flatChildren = flattenSchemaLeaves(schema.children, '$')
        flatChildren.forEach(child => {
          elementMappings.push({
            sourceKey: child.jsonPath,
            targetKey: '',
            _schemaType: child.schema.type
          })
        })
      }
      ocrOutputMappingArray.value.push({ key: jsonPath, value: '', schema, isArray: true, elementMapping: elementMappings })
    } else {
      ocrOutputMappingArray.value.push({ key: jsonPath, value: '', schema })
    }
    // 删除所有祖先和后代路径的映射
    ocrOutputMappingArray.value = ocrOutputMappingArray.value.filter((m: any) => {
      const isRelated = isAncestorPath(jsonPath, m.key) || isAncestorPath(m.key, jsonPath)
      if (isRelated) {
        const isArrayRelated = isListType(schema?.type || '') || isListType(m.schema?.type || '')
        return !isRelated || isArrayRelated
      }
      return true
    })
  }
}

// 更新 OCR 输出映射的变量绑定
const updateOcrOutputMappingValue = (jsonPath: string, value: string) => {
  const mapping = ocrOutputMappingArray.value.find((m: any) => m.key === jsonPath)
  if (mapping) {
    mapping.value = value
  }
}

// 更新 OCR 数组映射的目标变量
const updateOcrArrayOutputTarget = (jsonPath: string, targetVar: string) => {
  const mapping = ocrOutputMappingArray.value.find((m: any) => m.key === jsonPath)
  if (mapping) {
    mapping.value = targetVar
    if (mapping.elementMapping) {
      mapping.elementMapping.forEach((em: any) => { em.targetKey = '' })
    }
  }
}

// 更新 OCR elementMapping 中某一项的目标属性
const updateOcrElementMappingTarget = (jsonPath: string, sourceKey: string, targetKey: string) => {
  const mapping = ocrOutputMappingArray.value.find((m: any) => m.key === jsonPath)
  if (mapping && mapping.elementMapping) {
    const em = mapping.elementMapping.find((e: any) => e.sourceKey === sourceKey)
    if (em) em.targetKey = targetKey
  }
}

// --- 新增变量弹窗逻辑 ---
const showAddVariableModal = ref(false)
const addingVariable = ref(false)
const newVariable = ref<any>({
  name: '',
  description: '',
  type: 'STRING'
})
const variableTypeOptions = [
  { label: '字符串 (STRING)', value: 'STRING' },
  { label: '数字 (NUMBER)', value: 'NUMBER' },
  { label: '布尔 (BOOLEAN)', value: 'BOOLEAN' },
  { label: '对象 (OBJECT)', value: 'OBJECT' },
  { label: '数组 (ARRAY)', value: 'ARRAY' }
]

const openAddVariableModal = () => {
  newVariable.value = { name: '', description: '', type: 'STRING' }
  showAddVariableModal.value = true
}

const handleAddVariable = async () => {
  if (!newVariable.value.name) {
    message.error('请输入变量名称')
    return
  }
  if (!props.intentId) {
    message.error('意图ID不存在')
    return
  }
  addingVariable.value = true
  try {
    await variableApi.create({
      intentId: props.intentId,
      name: newVariable.value.name,
      description: newVariable.value.description,
      type: newVariable.value.type
    })
    message.success('变量添加成功')
    showAddVariableModal.value = false
    await fetchVariables()
    emits('variable-added')
  } catch (error) {
    message.error('添加变量失败')
  } finally {
    addingVariable.value = false
  }
}

const resetValidation = () => {
  validation.value = {
    required: true,
    rules: []
  }
}

// --- 分支步骤相关 ---
// --- 周期与事件 ---
const handleAfterLeave = () => resetForm()
const resetForm = () => {
  form.value = initFormState()
  validation.value = { required: true, rules: [] }
  coreActions.value = []
  ocrActionEnabled.value = false
  ocrConfig.value = { targetProcessor: '', _selectedBean: '', _selectedMethod: '', _methodMetadata: null }
  ocrOutputMappingArray.value = []
  // 不清理 actionMetadata，保留缓存
}

const handleVarChange = (values: string[]) => {
  // 校验规则已改为路径级联模式，不再按变量名清理
}

const rules = computed(() => ({
  name: { required: true, message: '请输入名称', trigger: 'blur' },
  stepType: { required: true, message: '请选择类型', trigger: 'change' },
  belongToPhase: { required: true, message: '请选择阶段', trigger: 'change' },
  prompt: (form.value.stepType === 'INPUT' || form.value.stepType === 'COMPLETED' || form.value.stepType === 'TRANSITION') ? { required: true, message: '请输入指令', trigger: 'blur' } : {},
  selectedVarNames: form.value.stepType === 'INPUT' ? { required: false, type: 'array', message: '请至少选择一个变量', trigger: 'change' } : {}
}))

watch(() => props.show, (val) => {
  if (val) {
    metadataConfigured.value = isMetadataApiConfigured()
    fetchVariables()
    fetchActionMetadata()
  }
})

// 当 actionMetadata 加载完成后，更新已有 action 的 _methodMetadata
watch(() => actionMetadata.value, (newMetadata) => {
  if (newMetadata.length > 0) {
    // 更新 OCR 配置的 _methodMetadata
    if (ocrConfig.value._selectedBean && ocrConfig.value._selectedMethod && !ocrConfig.value._methodMetadata) {
      const ocrMethodMeta = getSelectedMethodMetadata(ocrConfig.value._selectedBean, ocrConfig.value._selectedMethod)
      if (ocrMethodMeta) {
        ocrConfig.value._methodMetadata = ocrMethodMeta

        if (ocrOutputMappingArray.value.length > 0) {
          const ocrSchemas = flattenReturnSchemas(ocrMethodMeta.returnSchema);
          ocrOutputMappingArray.value = ocrOutputMappingArray.value.map((m: any) => {
            const found = ocrSchemas.find(s => s.jsonPath === m.key);
            const schema = found ? found.schema : m.schema;
            // 如果是数组类型映射，补充 elementMapping 的 _schemaType 或重新生成
            if (m.isArray && schema && isListType(schema.type) && schema.children?.length > 0) {
              const leaves = flattenSchemaLeaves(schema.children, '$')
              if (!m.elementMapping || m.elementMapping.length === 0) {
                m.elementMapping = leaves.map((l: any) => ({ sourceKey: l.jsonPath, targetKey: '', _schemaType: l.schema.type }))
              } else {
                m.elementMapping.forEach((em: any) => {
                  const leaf = leaves.find((l: any) => l.jsonPath === em.sourceKey)
                  if (leaf) em._schemaType = leaf.schema.type
                })
              }
            }
            return { ...m, schema };
          });
          ocrOutputMappingArray.value.forEach((m: any) => {
            if (m.value && !isTypeBindable(m.schema)) {
              m.value = '';
            }
          });
        }
      }
    }
  }
  if (newMetadata.length > 0 && coreActions.value.length > 0) {
    coreActions.value.forEach(action => {
      if (action._selectedBean && action._selectedMethod && !action._methodMetadata) {
        const methodMeta = getSelectedMethodMetadata(action._selectedBean, action._selectedMethod)
        if (methodMeta) {
          action._methodMetadata = methodMeta

          // 如果已有入参映射数据，需要合并 schema 信息并重建结构
          if (action._inputMappingArray.length > 0) {
            const existingMappings = new Map(action._inputMappingArray.map((m: any) => [m.path || m.key, m]))

            // 初始化顶层参数
            const newMappings: InputMappingItem[] = []

            const processParam = (param: PropertySchema, prefix: string, depth: number, parentId?: string) => {
              const currentPath = prefix ? `${prefix}.${param.name}` : param.name
              const existing = existingMappings.get(currentPath)
              const isParent = param.complex && param.children && param.children.length > 0
              const isList = isListType(param.type)

              // 检查是否有子属性的映射存在（说明需要展开）
              const hasChildMappings = Array.from(existingMappings.keys()).some(
                k => k.startsWith(currentPath + '.') || k.startsWith(currentPath + '[')
              )

              const item: InputMappingItem = {
                id: generateInputMappingId(),
                path: currentPath,
                schema: param,
                depth,
                sourceType: existing?.sourceType || (hasChildMappings ? 'expand' : 'context'),
                value: existing?.value || '',
                isParent,
                isExpanded: hasChildMappings,
                isListItem: false,
                parentId
              }
              newMappings.push(item)

              // 如果有子映射，递归处理子属性
              if (hasChildMappings && !isList && param.children) {
                param.children.forEach(child => {
                  processParam(child, currentPath, depth + 1, item.id)
                })
              }

              // 处理集合项
              if (isList && hasChildMappings) {
                // 找出所有集合项
                const listItemPaths = Array.from(existingMappings.keys())
                  .filter(k => k.match(new RegExp(`^${currentPath.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}\\[\\d+\\]`)))
                  .map(k => k.match(/\[(\d+)\]/)?.[1])
                  .filter((v, i, a) => v && a.indexOf(v) === i)
                  .map(Number)
                  .sort((a, b) => a - b)

                listItemPaths.forEach(idx => {
                  const listItemPath = `${currentPath}[${idx}]`
                  const listItemId = generateInputMappingId()

                  // 添加集合项容器
                  if (param.children && param.children.length > 0) {
                    newMappings.push({
                      id: listItemId,
                      path: listItemPath,
                      schema: { ...param, name: `[${idx}]`, type: '对象' },
                      depth: depth + 1,
                      sourceType: 'expand',
                      value: '',
                      isParent: true,
                      isExpanded: true,
                      isListItem: true,
                      listIndex: idx,
                      parentId: item.id
                    })

                    // 添加集合项的子属性
                    param.children.forEach(child => {
                      const childPath = `${listItemPath}.${child.name}`
                      const childExisting = existingMappings.get(childPath)

                      newMappings.push({
                        id: generateInputMappingId(),
                        path: childPath,
                        schema: child,
                        depth: depth + 2,
                        sourceType: childExisting?.sourceType || 'context',
                        value: childExisting?.value || '',
                        isParent: child.complex && child.children && child.children.length > 0,
                        isExpanded: false,
                        isListItem: false,
                        parentId: listItemId
                      })
                    })
                  } else {
                    // 基础类型集合项
                    const itemExisting = existingMappings.get(listItemPath)
                    newMappings.push({
                      id: listItemId,
                      path: listItemPath,
                      schema: { name: `[${idx}]`, type: 'String', description: '', complex: false, children: [] },
                      depth: depth + 1,
                      sourceType: itemExisting?.sourceType || 'context',
                      value: itemExisting?.value || '',
                      isParent: false,
                      isExpanded: false,
                      isListItem: true,
                      listIndex: idx,
                      parentId: item.id
                    })
                  }
                })
              }
            }

            methodMeta.parameters.forEach(param => {
              processParam(param, '', 0)
            })

            action._inputMappingArray = newMappings
          } else {
            // 如果没有已有映射，使用新的初始化逻辑
            action._inputMappingArray = initializeInputMappings(methodMeta.parameters)
          }
          if (action._outputMappingArray.length > 0) {
            const allSchemas = flattenReturnSchemas(methodMeta.returnSchema);
            action._outputMappingArray = action._outputMappingArray.map((m: any) => {
              const found = allSchemas.find(s => s.jsonPath === m.key);
              const schema = found ? found.schema : m.schema;
              // 如果是数组类型映射，补充 elementMapping 的 _schemaType 或重新生成
              if (m.isArray && schema && isListType(schema.type) && schema.children?.length > 0) {
                const leaves = flattenSchemaLeaves(schema.children, '$')
                if (!m.elementMapping || m.elementMapping.length === 0) {
                  m.elementMapping = leaves.map((l: any) => ({ sourceKey: l.jsonPath, targetKey: '', _schemaType: l.schema.type }))
                } else {
                  // 为已有的 elementMapping 补充 _schemaType
                  m.elementMapping.forEach((em: any) => {
                    const leaf = leaves.find((l: any) => l.jsonPath === em.sourceKey)
                    if (leaf) em._schemaType = leaf.schema.type
                  })
                }
              }
              return { ...m, schema };
            });
            action._outputMappingArray.forEach((m: any) => {
              if (m.value && !isTypeBindable(m.schema)) {
                m.value = '';
              }
            });
          }
        }
      }
    })
  }
}, { deep: true })

// 优化点：当类型为完成时，阶段固定为结束收尾且不可选；当类型为ACTION时，canSkip固定为false
watch(() => form.value.stepType, (newVal) => {
  if (newVal === 'COMPLETED') {
    form.value.belongToPhase = 'CLOSING'
  }
  if (newVal === 'ACTION') {
    form.value.canSkip = false
  }
})

watch(() => props.step, (newStep) => {
  if (!newStep) return
  const baseForm = { ...newStep }
  
  try {
    baseForm.isDirectReturn = newStep.isDirectReturn ?? 0

    // 1. 解析已选变量名
    if (newStep.expectedInputsJson) {
      baseForm.selectedVarNames = Object.keys(JSON.parse(newStep.expectedInputsJson))
    }

    // 2. 解析校验规则 (支持新旧两种格式)
    if (newStep.validationJson) {
      const vData = JSON.parse(newStep.validationJson)
      if (vData.rules) {
        // 新格式：统一规则列表
        validation.value = {
          required: vData.required ?? true,
          rules: (vData.rules || []).map((r: any) => ({
            ...r,
            // 优先读取保存的 template 字段，如果没有则尝试匹配现有模板
            _template: r.template || '' 
          }))
        }
      } else {
        // 旧格式：分类规则 -> 转换为统一规则列表
        const rules: any[] = []
        for (const r of vData.regexRules || []) {
          rules.push({ path: `$.${r.field}`, ruleType: 'REGEX', criterion: r.pattern, error: r.error || '', _template: '' })
        }
        for (const r of vData.optionRules || []) {
          rules.push({ path: `$.${r.field}`, ruleType: 'ENUM', options: r.options || [], error: r.error || '', _template: '' })
        }
        for (const r of vData.rangeRules || []) {
          rules.push({ path: `$.${r.field}`, ruleType: 'RANGE', min: r.min, max: r.max, error: r.error || '', _template: '' })
        }
        validation.value = {
          required: vData.required ?? true,
          rules
        }
      }
    } else {
      resetValidation()
    }

    // 3. 解析业务动作回显 (ACTION)
    if (newStep.coreActionsJson) {
      const parsedActions = JSON.parse(newStep.coreActionsJson)
      coreActions.value = parsedActions.map((a: any) => {
        // 解析 targetProcessor 获取 bean 和 method
        const [beanName, methodName] = (a.targetProcessor || '').split('.')

        // 将已有的 inputMapping 转换为新的数据结构
        const existingInputMappings = Object.entries(a.inputMapping || {}).map(([k, v]) => {
          // 解析路径层级
          const pathParts = k.replace(/\[\d+\]/g, '.[*]').split('.')
          const isListItem = k.includes('[')
          const listIndex = isListItem ? parseInt(k.match(/\[(\d+)\]/)?.[1] || '0') : undefined

          return {
            id: generateInputMappingId(),
            path: k,
            key: k,
            schema: {
              name: pathParts[pathParts.length - 1] || k,
              type: 'String',
              description: '',
              complex: false,
              children: []
            },
            depth: pathParts.length - 1,
            sourceType: (typeof v === 'string' && v.startsWith('$.')) ? 'context' as const : 'constant' as const,
            value: v,
            isParent: false,
            isExpanded: false,
            isListItem,
            listIndex
          }
        })

        return {
          ...a,
          _selectedBean: beanName || '',
          _selectedMethod: methodName || '',
          _methodMetadata: null, // 将在 actionMetadata 加载后更新
          _inputMappingArray: existingInputMappings,
          _outputMappingArray: Object.entries(a.outputMapping || {}).map(([k, v]: [string, any]) => {
            if (typeof v === 'object' && v !== null && v.type === 'ARRAY') {
              return {
                key: k,
                value: v.target,
                isArray: true,
                elementMapping: Object.entries(v.elementMapping || {}).map(([sk, tk]) => ({
                  sourceKey: sk,
                  targetKey: tk,
                  _schemaType: ''
                }))
              }
            }
            return { key: k, value: v }
          })
        }
      })
    } else {
      coreActions.value = []
    }

    // 4. 【核心修复】图片识别执行器回显 (使用新变量名 ocrConfig)
    if (newStep.ocrAction && newStep.ocrAction !== '') {
      const ocrData = JSON.parse(newStep.ocrAction)
      ocrActionEnabled.value = true
      const [ocrBeanName, ocrMethodName] = (ocrData.targetProcessor || '').split('.')
      ocrConfig.value = {
        targetProcessor: ocrData.targetProcessor || '',
        _selectedBean: ocrBeanName || '',
        _selectedMethod: ocrMethodName || '',
        _methodMetadata: null
      }
      // 尝试从已加载的 actionMetadata 中获取方法元数据
      if (ocrBeanName && ocrMethodName) {
        const ocrMethodMeta = getSelectedMethodMetadata(ocrBeanName, ocrMethodName)
        if (ocrMethodMeta) {
          ocrConfig.value._methodMetadata = ocrMethodMeta
        }
      }
      ocrOutputMappingArray.value = Object.entries(ocrData.outputMapping || {}).map(([k, v]: [string, any]) => {
        if (typeof v === 'object' && v !== null && v.type === 'ARRAY') {
          return {
            key: k,
            value: v.target,
            isArray: true,
            elementMapping: Object.entries(v.elementMapping || {}).map(([sk, tk]) => ({
              sourceKey: sk,
              targetKey: tk,
              _schemaType: ''
            }))
          }
        }
        return { key: k, value: v }
      })
    } else {
      ocrActionEnabled.value = false
      ocrConfig.value = { targetProcessor: '', _selectedBean: '', _selectedMethod: '', _methodMetadata: null }
      ocrOutputMappingArray.value = []
    }

  } catch (e) { 
    console.error("解析回显数据失败:", e) 
  }
  form.value = baseForm
}, { immediate: true })

const handleSave = async () => {
  try {
    await formRef.value?.validate()
    saving.value = true
    
    // --- 注意这里的变量名修改：ocrActionData ---
    let expectedInputsJson = '', validationJson = '', coreActionsJson = '', ocrActionData = '' 
    
    if (form.value.stepType === 'INPUT') {
      const iMap: any = {};
      (form.value.selectedVarNames || []).forEach((n: string) => {
        // 在变量池中找到选中的顶层变量
        const vInfo = availableVariables.value.find(v => v.name === n);
        if (vInfo) {
          // 使用递归函数生成完整的结构描述
          iMap[n] = buildVariableSchema(vInfo);
        } else {
          iMap[n] = 'STRING';
        }
      });
      // 转换成 JSON 字符串，供 Prompt 引用
      expectedInputsJson = JSON.stringify(iMap, null, 2); 
      const cleanRules = validation.value.rules
        .filter((r: any) => r.path && r.ruleType)
        .map((r: any) => {
          // 将内部使用的 _template 转换为持久化的 template 字段
          const { _template, ...rest } = r;
          return {
            ...rest,
            template: _template || '' // 确保这个字段被保存
          };
        })
      validationJson = JSON.stringify({ required: validation.value.required, rules: cleanRules })
      
      // 处理图片识别执行器
      if (ocrActionEnabled.value) {
        const oM: any = {}
        ocrOutputMappingArray.value.forEach((m: any) => {
          if (!m.key || !m.value) return
          if (m.isArray && m.elementMapping) {
            const elemMap: any = {}
            m.elementMapping.forEach((em: any) => {
              if (em.sourceKey && em.targetKey) {
                elemMap[em.sourceKey] = em.targetKey
              }
            })
            oM[m.key] = {
              target: (!m.value || m.value === 'ELEMENT_MAPPING_MODE') ? null : m.value,
              type: 'ARRAY',
              elementMapping: elemMap
            }
          } else {
            oM[m.key] = m.value
          }
        })
        // 注意这里改为从 ocrConfig.value 获取
        ocrActionData = JSON.stringify({
          targetProcessor: ocrConfig.value.targetProcessor,
          inputMapping: {},
          outputMapping: oM
        })
      }
    }
    
    if (form.value.stepType === 'ACTION') {
      coreActionsJson = JSON.stringify(coreActions.value.map(a => {
        const iM: any = {}, oM: any = {}
        // 处理入参映射：只处理有实际值的叶子节点
        a._inputMappingArray.forEach((m: any) => {
          const key = m.path || m.key
          // 跳过已展开的父节点（它们的子节点会单独处理）
          if (m.sourceType === 'expand' || (m.isParent && m.isExpanded)) {
            return
          }
          // 集合类型：如果是手动模式，跳过根节点（它们的项会单独处理）；如果是变量模式，保存变量值
          if (isListType(m.schema?.type || '') && !m.isListItem) {
            if (m.sourceType === 'manual') {
              return
            }
            // 变量模式，保存变量值
            if (m.sourceType === 'context' && m.value) {
              iM[key] = m.value
            }
            return
          }
          // 只有有值的项才生成映射
          if (key && (m.value !== '' && m.value !== undefined && m.value !== null)) {
            iM[key] = m.value
          }
        })
        // 处理出参映射
        a._outputMappingArray.forEach((m: any) => {
          if (!m.key || !m.value) return
          
          if (m.isArray && m.elementMapping) {
            const elemMap: any = {}
            m.elementMapping.forEach((em: any) => {
              if (em.sourceKey && em.targetKey) {
                elemMap[em.sourceKey] = em.targetKey
              }
            })
            
            // 如果整体绑定(m.value)是标记位，说明只需要成员提取
            oM[m.key] = {
              target: (!m.value || m.value === 'ELEMENT_MAPPING_MODE') ? null : m.value, // null 表示不绑定整体
              type: 'ARRAY',
              elementMapping: elemMap
            }
          } else {
            oM[m.key] = m.value
          }
        })
        return { targetProcessor: a.targetProcessor, inputMapping: iM, outputMapping: oM }
      }))
    }
    
    const { selectedVarNames, ...rest } = form.value
    // --- 这里是关键：将 ocrActionData 映射为后端的 ocrAction 字段 ---
    emits('save', { 
      ...rest, 
      expectedInputsJson, 
      validationJson, 
      coreActionsJson, 
      ocrAction: ocrActionData  // 确保传给后端的是这个字符串
    })
    
  } catch (e) { 
    console.error('保存失败详情:', e) 
  } finally { 
    saving.value = false 
  }
}

// 递归构建变量的描述结构
const buildVariableSchema = (variable: FlowVariable): any => {
  // 如果没有子项（基础类型），直接返回描述 + 类型
  if (!variable.children || variable.children.length === 0) {
    return `${variable.description || ''} (${variable.type})`;
  }

  // 如果是 ARRAY 类型
  if (variable.type === 'ARRAY') {
    // 数组通常取第一个子项作为模板描述
    return [buildVariableSchema(variable.children[0])];
  }

  // 如果是 OBJECT 类型
  if (variable.type === 'OBJECT') {
    const schema: any = {};
    variable.children.forEach(child => {
      schema[child.name] = buildVariableSchema(child);
    });
    return schema;
  }

  return variable.type;
}
</script>

<style scoped>
.section-title {
  font-size: 1rem;
  font-weight: 700;
  color: #1f2937;
  letter-spacing: -0.01em;
}

.config-section {
  border: 1px solid #e5e7eb;
  padding: 20px;
  border-radius: 16px;
  background: linear-gradient(to bottom, #ffffff, #f9fafb);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
  transition: all 0.2s ease;
}

.config-section:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.validation-group {
  background: #f8fafc;
  padding: 16px;
  border-radius: 12px;
  border: 1px solid #e2e8f0;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.03);
}

/* Action Configuration Styles */
.action-card {
  border: 1px solid #e5e7eb;
  background: #ffffff;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
  transition: all 0.2s ease;
}

.action-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.step-box {
  position: relative;
}

.step-header {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}

.step-num {
  width: 24px;
  height: 24px;
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: #fff;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 700;
  margin-right: 10px;
  box-shadow: 0 2px 4px rgba(16, 185, 129, 0.3);
}

.step-title {
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

.text-primary {
  color: #10b981;
}

/* 专项修复：当 radio-button 被 tooltip 包裹时恢复其分割线样式 */
:deep(.n-radio-group) {
  gap: 0;
}

:deep(.n-radio-button) {
  border-radius: 0;
  transition: all 0.2s ease;
}

:deep(.n-radio-button:hover) {
  transform: translateY(-1px);
}

:deep(.n-tooltip-wrapper:first-child .n-radio-button) {
  border-top-left-radius: 6px;
  border-bottom-left-radius: 6px;
}

:deep(.n-tooltip-wrapper:last-child .n-radio-button) {
  border-top-right-radius: 6px;
  border-bottom-right-radius: 6px;
  border-left-width: 0;
}

:deep(.n-tooltip-wrapper + .n-tooltip-wrapper .n-radio-button) {
  border-left: 1px solid var(--n-button-border-color);
}

/* 优化表单元素 */
:deep(.n-input) {
  border-radius: 8px;
  transition: all 0.2s ease;
}

:deep(.n-input:focus-within) {
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

:deep(.n-select .n-base-selection) {
  border-radius: 8px;
  transition: all 0.2s ease;
}

:deep(.n-select .n-base-selection:focus-within) {
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

:deep(.n-switch) {
  transition: all 0.2s ease;
}

:deep(.n-button) {
  border-radius: 8px;
  transition: all 0.2s ease;
  font-weight: 500;
}

:deep(.n-button:hover) {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

:deep(.n-button:active) {
  transform: translateY(0);
}

/* 优化标签页 */
:deep(.n-tabs .n-tabs-nav) {
  border-radius: 12px 12px 0 0;
}

:deep(.n-tabs .n-tab-pane) {
  padding-top: 16px;
}

/* 优化折叠面板 */
:deep(.n-collapse .n-collapse-item) {
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.04);
}

:deep(.n-collapse .n-collapse-item__header) {
  background: linear-gradient(to right, #f9fafb, #ffffff);
  font-weight: 600;
  transition: all 0.2s ease;
}

:deep(.n-collapse .n-collapse-item__header:hover) {
  background: linear-gradient(to right, #f3f4f6, #f9fafb);
}

/* 优化徽章 */
:deep(.n-badge) {
  border-radius: 12px;
  font-weight: 600;
  letter-spacing: 0.02em;
}

/* 优化分隔线 */
:deep(.n-divider) {
  margin: 24px 0;
}

/* 滚动条优化 */
.step-edit-form {
  max-height: 75vh;
  overflow-y: auto;
  padding-right: 4px;
}

.step-edit-form::-webkit-scrollbar {
  width: 6px;
}

.step-edit-form::-webkit-scrollbar-track {
  background: #f3f4f6;
  border-radius: 10px;
}

.step-edit-form::-webkit-scrollbar-thumb {
  background: #d1d5db;
  border-radius: 10px;
}

.step-edit-form::-webkit-scrollbar-thumb:hover {
  background: #9ca3af;
}

/* 类型不匹配警告样式 */
.type-warning :deep(.n-base-selection) {
  border-color: #f0a020 !important;
  box-shadow: 0 0 0 2px rgba(240, 160, 32, 0.2) !important;
}

/* 参数树容器样式 */
.param-tree-container {
  background: #fff;
}

/* 返回结构树样式 */
.return-schema-tree {
  background: #fff;
  max-height: 300px;
  overflow-y: auto;
}

.return-schema-tree::-webkit-scrollbar {
  width: 4px;
}

.return-schema-tree::-webkit-scrollbar-thumb {
  background: #d1d5db;
  border-radius: 4px;
}

/* 展开/收起按钮旋转动画 */
.rotate-90 {
  transform: rotate(90deg);
  transition: transform 0.2s ease;
}

/* 参数树行样式优化 */
.param-tree-container > div:not(:first-child):hover {
  background-color: #f9fafb;
}

/* 集合项和展开项的背景色 */
.bg-blue-50\/30 {
  background-color: rgba(239, 246, 255, 0.3);
}

.bg-amber-50\/30 {
  background-color: rgba(255, 251, 235, 0.3);
}

/* 在 <style scoped> 中添加 */
.truncate {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: inline-block;
  max-width: 100%;
}

/* 确保 tooltip 触发器容器宽度正常 */
:deep(.n-tooltip-trigger) {
  display: flex;
  justify-content: center;
  width: 100%;
  overflow: hidden;
}
</style>