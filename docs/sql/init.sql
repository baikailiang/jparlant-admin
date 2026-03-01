CREATE DATABASE IF NOT EXISTS jparlant CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE jparlant;




-- 规则引擎表
CREATE TABLE `compliance_rules` (
    `id` bigint(20) AUTO_INCREMENT PRIMARY KEY,
    `agent_id` bigint(20) NOT NULL COMMENT '所属AgentID',
    -- 核心识别字段
    `name` VARCHAR(100) NOT NULL COMMENT '规则名称',
    `description` VARCHAR(255) DEFAULT NULL COMMENT '描述',
    `scope` VARCHAR(20) NOT NULL DEFAULT 'ALL' COMMENT '作用域: INPUT(检查用户输入), RESPONSE(检查AI回复), ALL(全量检查)',
    -- 判定逻辑字段
    `keywords` JSON DEFAULT NULL COMMENT '关键词列表 (JSON Array) - 第一层漏斗',
    `parameters` JSON DEFAULT NULL COMMENT '规则参数 (JSON Object: {"regex_patterns": ["..."]}) - 第二层漏斗',
    `condition_expr` TEXT DEFAULT NULL COMMENT 'SpEL触发条件表达式 - 第三层漏斗',
    -- 响应处理字段
    `blocked_response` TEXT DEFAULT NULL COMMENT '拦截后返回给用户的标准话术或提示',
    -- 管理与监控字段
    `categories` JSON DEFAULT NULL COMMENT '自定义分类标签 (JSON Array)',
    `priority` INT NOT NULL DEFAULT 1 COMMENT '优先级',
    `enabled` TINYINT(1) NOT NULL DEFAULT 1 COMMENT '状态: 0禁用, 1启用',
    -- 审计字段
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `guideline_prompt` TEXT DEFAULT NULL COMMENT '规则prompt',
    -- 索引优化
    -- 1. 最核心的查询索引：按Agent、状态、作用域和优先级过滤
    INDEX `idx_agent_scope_enabled_priority` (`agent_id`, `scope`, `enabled`, `priority`),
    -- 2. 方便后台管理查询
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='合规检查规则引擎配置表';


-- 术语定义表
CREATE TABLE `glossary` (
    `id` bigint(64) AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL COMMENT '术语名称',
    `definition` TEXT NOT NULL COMMENT '定义描述',
    `category` VARCHAR(50) NOT NULL COMMENT '分类',
    `synonyms` JSON DEFAULT NULL COMMENT '同义词列表 (JSON Array)',
    `related_names` JSON DEFAULT NULL COMMENT '相关术语 (JSON Array)',
    `examples` JSON DEFAULT NULL COMMENT '示例 (JSON Object)',
    `agent_id` bigint(64) NOT NULL COMMENT '所属Agent',
    `priority` INT NOT NULL DEFAULT 1 COMMENT '优先级',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_agent_id` (`agent_id`) -- 必须加索引，用于缓存加载
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='业务词汇术语表';



-- Agent定义表
CREATE TABLE agents (
    `id` bigint(64) AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `instructions` TEXT,
    `description` TEXT,
    `keywords` VARCHAR(500),
    `status` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NOT NULL,
    `updated_at` TIMESTAMP NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='agent定义表';



-- Agent 意图定义表
CREATE TABLE `agent_intent` (
    `id` bigint(64) AUTO_INCREMENT PRIMARY KEY,
    `agent_id` bigint(64) NOT NULL COMMENT '所属Agent ID',
    `name` VARCHAR(100) NOT NULL COMMENT '意图名称',
    `description` TEXT COMMENT '意图的详细描述，交给LLM识别用',
    `flow_type` VARCHAR(20) DEFAULT 'LINEAR' COMMENT '流程类型: LINEAR, CONDITIONAL, LOOP, INTERACTIVE',
    `metadata_json` TEXT COMMENT '流程元数据 Map<String, Object> 的 JSON 格式',
    `enabled` TINYINT(1) DEFAULT 1 COMMENT '是否启用',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='Agent意图及流程主表';


-- 意图对应的业务步骤表
CREATE TABLE `intent_step` (
    `id` bigint(64) AUTO_INCREMENT PRIMARY KEY,
    `intent_id` bigint(64) NOT NULL COMMENT '所属意图ID',
    `name` VARCHAR(100) NOT NULL COMMENT '步骤名称',
    `description` TEXT COMMENT '步骤描述，用于指导LLM判断进度',
    `belongToPhase` VARCHAR(20) DEFAULT 'READY' COMMENT '步骤所属阶段: READY, PROLOGUE, UNDERSTANDING, PROCESSING, REVIEW, PENDING, HANDOVER, SUSPENDED, CLOSING, ARCHIVED, TERMINATED',
    `priority` INT DEFAULT 1 COMMENT '主干顺序（用于默认直线流程）',
    `step_type` VARCHAR(20) DEFAULT 'INPUT' COMMENT '步骤类型: INPUT, ACTION, COMPLETED',
    `prompt` TEXT COMMENT '引导用户的提示语',
    `expected_inputs_json` TEXT COMMENT '期望的用户输入类型 Map<String, String> 的 JSON 格式',
    `validation_json` TEXT COMMENT '输入验证规则 Map<String, Object> 的 JSON 格式',
    `dependencies` TEXT COMMENT '前置依赖步骤的id集合 List<Long>',
    `can_skip` TINYINT(1) DEFAULT 0 COMMENT '是否允许跳过, 0不允许，1允许',
    `skip_to_prompt` TEXT COMMENT '跳跃时的引导提示语',
    `ocr_action` TEXT COMMENT '图片识别执行器',
    `core_actions_json` TEXT COMMENT '核心逻辑 List<ActionCall> JSON'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='意图业务步骤明细表';


CREATE TABLE `intent_step_transition` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `intent_id` BIGINT NOT NULL COMMENT '所属意图',
    `from_step_id` BIGINT NOT NULL COMMENT '起始步骤',
    `to_step_id` BIGINT NOT NULL COMMENT '目标步骤',
    `branch_code` VARCHAR(50) DEFAULT 'DEFAULT' COMMENT '分支标识，如 DEFAULT / A / B / NEED_VERIFY / SKIP',
    `condition_json` TEXT COMMENT '触发条件（基于上下文、用户输入、状态）',
    `priority` INT DEFAULT 1 COMMENT '同一个 from_step 下的分支顺序',
    `is_default` TINYINT(1) DEFAULT 0 COMMENT '是否默认分支,0否，1是',
    KEY `idx_from_step` (`from_step_id`),
    KEY `idx_intent_from` (`intent_id`, `from_step_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='步骤流转 / 分支关系表';



CREATE TABLE `flow_variable` (
    `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `intent_id` bigint NOT NULL COMMENT '所属意图 ID',
    `parent_id` bigint DEFAULT NULL COMMENT '父级ID（用于对象属性或数组元素定义）',
    `name` varchar(64) DEFAULT NULL COMMENT '变量名称（如果是数组元素，名称可为空）',
    `description` varchar(255) DEFAULT NULL COMMENT '变量描述',
    `type` varchar(32) NOT NULL COMMENT '类型: STRING, NUMBER, BOOLEAN, OBJECT, ARRAY',
    `is_required` tinyint(1) DEFAULT '0' COMMENT '是否必填',
    `default_value` text DEFAULT NULL COMMENT '默认值',
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_intent_parent_name` (`intent_id`, `parent_id`, `name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='流程变量结构定义表';



-- 合规违规记录表
CREATE TABLE `compliance_violations` (
    `id` bigint(64) AUTO_INCREMENT PRIMARY KEY,
    `agent_id` bigint(64) NOT NULL COMMENT '所属智能体ID',
    `rule_id` bigint(64) NOT NULL COMMENT '触发的规则ID',
    `rule_name` VARCHAR(255) COMMENT '规则快照名称',
    `compliance_level` VARCHAR(20) COMMENT '违规等级快照',
    `content` TEXT COMMENT '导致违规的原始文本内容',
    `session_id` VARCHAR(100) COMMENT '会话ID',
    `user_id` VARCHAR(100) COMMENT '用户唯一标识',
    `phase` VARCHAR(20) DEFAULT 'INPUT' COMMENT '拦截阶段: INPUT, PROCESSING, RESPONSE',
    `violation_data_json` TEXT COMMENT '违规详情元数据 Map 的 JSON 格式',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '违规发生时间',
    INDEX `idx_session_id` (`session_id`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_agent_id` (`agent_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='合规违规拦截流水表';



-- 工具执行日志表
CREATE TABLE `tool_execution_logs` (
    `id` bigint(64) AUTO_INCREMENT PRIMARY KEY,
    `agent_id` bigint(64) NOT NULL COMMENT '所属智能体ID',
    `tool_name` VARCHAR(255) NOT NULL COMMENT '调用的工具/Action名称',
    `session_id` VARCHAR(100) COMMENT '会话ID',
    `user_id` VARCHAR(100) COMMENT '用户唯一标识',
    `parameters_json` TEXT COMMENT '调用的输入参数 JSON',
    `execution_result_json` TEXT COMMENT '工具返回的原始结果 JSON',
    `success` TINYINT(1) DEFAULT 0 COMMENT '是否执行成功',
    `execution_time_ms` BIGINT COMMENT '执行耗时(毫秒)',
    `error_message` TEXT COMMENT '失败时的错误堆栈/描述',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '记录时间',
    INDEX `idx_tool_name` (`tool_name`),
    INDEX `idx_session_id` (`session_id`),
    INDEX `idx_agent_id` (`agent_id`),
    INDEX `idx_success` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='外部工具/Action调用执行日志';







INSERT INTO `agents` (`id`, `name`, `instructions`, `description`, `keywords`, `status`, `created_at`, `updated_at`) VALUES (1, '贷款助手', '你是一个专业的银行贷款助手。你的任务是引导用户完成贷款申请流程。\r\n1. 必须按照业务步骤顺序进行，不要跳步。\r\n2. 语气要专业、亲切。\r\n3. 如果用户输入违规或不合规，礼貌地告知并引导其重新输入。你是一个专业的银行贷款助手。你的任务是引导用户完成贷款申请流程。你是一个专业的银行贷款助手。你的任务是引导用户完成贷款申请流程。你是一个专业的银行贷款助手。你的任务是引导用户完成贷款申请流程。', '负责个人信用贷款的在线申请、信息采集与初步额度评估。负责个人信用贷款的在线申请、信息采集与初步额度评估。', '贷款,银行,工资,薪资', 1, '2026-01-27 09:57:44', '2026-02-12 11:03:44');

INSERT INTO `agent_intent` (`id`, `agent_id`, `name`, `description`, `flow_type`, `metadata_json`, `enabled`, `created_at`, `updated_at`) VALUES (100, 1, '个人贷款申请', '用户表达了想要借款、申请贷款或查询额度的意图。', 'LINEAR', '{"nodePositions":{"67":{"x":526.1173950044702,"y":164.22182261534863},"68":{"x":781,"y":455},"69":{"x":401.7511423939121,"y":691.946221501641},"70":{"x":740.684979998799,"y":902.6931624944804},"71":{"x":789.2277076186684,"y":1170.2507456992698},"72":{"x":1066.718511944217,"y":1403.4141571333896},"73":{"x":1213,"y":689}},"edges":[{"id":"edge-67-68-1771406415699","source":"67","target":"68","label":"","data":{"condition":null,"transitionLabel":"","isDefault":1},"type":"smoothstep"},{"id":"edge-68-73-1771406825215","source":"68","target":"73","label":"其他","data":{"condition":null,"transitionLabel":"其他","isDefault":1},"type":"smoothstep"},{"id":"edge-69-70-1771407179852","source":"69","target":"70","label":"","data":{"condition":null,"transitionLabel":"","isDefault":1},"type":"smoothstep"},{"id":"edge-70-71-1771407192755","source":"70","target":"71","label":"","data":{"condition":null,"transitionLabel":"","isDefault":1},"type":"smoothstep"},{"id":"edge-71-72-1771407197915","source":"71","target":"72","label":"","data":{"condition":null,"transitionLabel":"","isDefault":1},"type":"smoothstep"},{"id":"edge-68-69-1771826048946","source":"68","target":"69","label":"不在黑名单","data":{"condition":"{\\"risk_assessment.is_in_blacklist\\":false}","transitionLabel":"不在黑名单","isDefault":0},"type":"smoothstep"}]}', 1, '2026-01-27 10:03:53', '2026-02-25 12:11:39');

INSERT INTO `intent_step` (`id`, `intent_id`, `name`, `description`, `belong_to_phase`, `priority`, `step_type`, `prompt`, `expected_inputs_json`, `validation_json`, `dependencies`, `can_skip`, `skip_to_prompt`, `core_actions_json`, `ocr_action`) VALUES (68, 100, '黑名单与信用预查', '调用后台风控接口，判断用户是否有资格继续。', 'PROCESSING', NULL, 'ACTION', '', '', '', NULL, 0, NULL, '[{"targetProcessor":"riskControlService.checkUserCredit","inputMapping":{"idCard":"$.applicant_profile.identity_info.card_no","mobile":"$.applicant_profile.mobile"},"outputMapping":{"$.score":"$.risk_assessment.credit_score","$.blacklisted":"$.risk_assessment.is_in_blacklist"}}]', '');
INSERT INTO `intent_step` (`id`, `intent_id`, `name`, `description`, `belong_to_phase`, `priority`, `step_type`, `prompt`, `expected_inputs_json`, `validation_json`, `dependencies`, `can_skip`, `skip_to_prompt`, `core_actions_json`, `ocr_action`) VALUES (70, 100, '根据贷款额和信用分，计算月供和还款计划表。', '', 'PROCESSING', NULL, 'ACTION', '', '', '', NULL, 0, NULL, '[{"targetProcessor":"loanCalculatorService.generateRepaymentPlan","inputMapping":{"principal":"$.loan_request.amount","months":"$.loan_request.term_months","userScore":"$.risk_assessment.credit_score"},"outputMapping":{"$.suggestedRate":"$.risk_assessment.suggested_rate","$.planList":{"target":"$.repayment_schedule","type":"ARRAY","elementMapping":{"$.period":"period","$.monthlyPayment":"monthly_payment","$.dueDate":"due_date"}}}}]', '');
INSERT INTO `intent_step` (`id`, `intent_id`, `name`, `description`, `belong_to_phase`, `priority`, `step_type`, `prompt`, `expected_inputs_json`, `validation_json`, `dependencies`, `can_skip`, `skip_to_prompt`, `core_actions_json`, `ocr_action`) VALUES (72, 100, '流程终结，向用户下发受理编号。', '', 'CLOSING', NULL, 'COMPLETED', '申请已提交！我们的客户经理会在 24 小时内通过 {{$.applicant_profile.mobile}} 与您联系。', '', '', NULL, 0, NULL, '', '');
INSERT INTO `intent_step` (`id`, `intent_id`, `name`, `description`, `belong_to_phase`, `priority`, `step_type`, `prompt`, `expected_inputs_json`, `validation_json`, `dependencies`, `can_skip`, `skip_to_prompt`, `core_actions_json`, `ocr_action`) VALUES (73, 100, '在黑名单，不能贷款', '', 'CLOSING', NULL, 'COMPLETED', '用户在黑名单，不能贷款', '', '', NULL, 0, NULL, '', '');
INSERT INTO `intent_step` (`id`, `intent_id`, `name`, `description`, `belong_to_phase`, `priority`, `step_type`, `prompt`, `expected_inputs_json`, `validation_json`, `dependencies`, `can_skip`, `skip_to_prompt`, `core_actions_json`, `ocr_action`) VALUES (67, 100, '收集用户的基本身份信息', '', 'UNDERSTANDING', NULL, 'INPUT', '任务目标：请引导用户提供姓名、手机号和身份证号。\n执行逻辑：\n1.如果用户未提供任何信息，请礼貌地开场并询问这三项信息。\n2.如果用户只提供了部分信息（如只说了姓名），请确认已收到的信息，并追问缺失的手机号和身份证号。\n话术要求：语气要专业且温和，强调信息仅用于贷款额度试算，会严格保密。', '{\n  "applicant_profile": {\n    "name": "姓名 (STRING)",\n    "mobile": "手机号 (STRING)",\n    "identity_info": {\n      "card_no": "身份证号 (STRING)",\n      "address": "户籍地址 (STRING)"\n    },\n    "is_first_loan": "是否首次贷款 (BOOLEAN)"\n  }\n}', '{"required":true,"rules":[{"path":"$.applicant_profile.identity_info.card_no","ruleType":"REGEX","criterion":"^[1-9]\\\\d{5}(18|19|20)\\\\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\\\\d|3[01])\\\\d{3}[0-9Xx]$","spelExpression":"","options":[],"properties":[],"error":"身份证号码不对","template":"idcard"},{"path":"$.applicant_profile.name","ruleType":"REGEX","criterion":"^[\\\\u4e00-\\\\u9fa5]+$","spelExpression":"","options":[],"properties":[],"error":"姓名不对","template":"chinese"}]}', NULL, 0, NULL, '', '');
INSERT INTO `intent_step` (`id`, `intent_id`, `name`, `description`, `belong_to_phase`, `priority`, `step_type`, `prompt`, `expected_inputs_json`, `validation_json`, `dependencies`, `can_skip`, `skip_to_prompt`, `core_actions_json`, `ocr_action`) VALUES (69, 100, '收集贷款需求与收入', '询问贷款额度、期限，并记录多条收入流水。\n', 'UNDERSTANDING', NULL, 'INPUT', '任务目标：收集用户的贷款金额、期限（月份）以及收入来源明细。\n执行逻辑：\n1.询问用户希望申请的贷款金额（建议范围 1k-50w）和还款期限。\n2.重点任务：引导用户列出其收入来源。用户可能会有多项收入（如工资、兼职、房租）。\n3.请通过循环追问的方式，为 $.income_streams 数组收集多个对象，每个对象必须包含 source_name（来源）和 amount（金额）。\n4.当用户说“没有其他收入了”或已经列举完毕后，再进入下一步。', '{\n  "income_streams": [\n    {\n      "source_name": "收入来源（如：工资、理财、兼职） (STRING)",\n      "amount": "月均金额 (NUMBER)",\n      "has_proof": "是否有纳税证明 (BOOLEAN)"\n    }\n  ],\n  "loan_request": {\n    "amount": "申请总金额 (NUMBER)",\n    "term_months": "贷款期限（月） (NUMBER)",\n    "category": "贷款用途（装修、购车、经营） (STRING)"\n  }\n}', '{"required":true,"rules":[{"path":"$.loan_request.amount","ruleType":"RANGE","template":"","criterion":"","spelExpression":"","min":1000,"max":500000,"options":[],"properties":[],"error":"贷款额度不满足"},{"path":"$.income_streams[*].Item.amount","ruleType":"RANGE","template":"","criterion":"","spelExpression":"","min":1,"max":99999999,"options":[],"properties":[],"error":"月工资流水不够"}]}', NULL, 0, NULL, '', '');
INSERT INTO `intent_step` (`id`, `intent_id`, `name`, `description`, `belong_to_phase`, `priority`, `step_type`, `prompt`, `expected_inputs_json`, `validation_json`, `dependencies`, `can_skip`, `skip_to_prompt`, `core_actions_json`, `ocr_action`) VALUES (71, 100, '展示试算结果，让用户确认是否申请。', '', 'REVIEW', NULL, 'INPUT', '根据您的信用分 {{\n.risk_assessment.suggested_rate}}%。首期还款日期为 {{$.repayment_schedule[0].due_date}}。您确认办理吗？', '{\n  "is_confirmed": "是否确认办理贷款 (BOOLEAN)"\n}', '{"required":true,"rules":[{"path":"$.is_confirmed","ruleType":"BOOLEAN_CHECK","template":"","criterion":"","spelExpression":"","options":[],"properties":[],"error":"输入不合法"}]}', NULL, 0, NULL, '', '');


INSERT INTO `intent_step_transition` (`id`, `intent_id`, `from_step_id`, `to_step_id`, `branch_code`, `condition_json`, `priority`, `is_default`) VALUES (136, 100, 67, 68, 'DEFAULT', NULL, 1, 1);
INSERT INTO `intent_step_transition` (`id`, `intent_id`, `from_step_id`, `to_step_id`, `branch_code`, `condition_json`, `priority`, `is_default`) VALUES (137, 100, 68, 69, '不在黑名单', '{"risk_assessment.is_in_blacklist":false}', 1, 0);
INSERT INTO `intent_step_transition` (`id`, `intent_id`, `from_step_id`, `to_step_id`, `branch_code`, `condition_json`, `priority`, `is_default`) VALUES (138, 100, 68, 73, '其他', NULL, 2, 1);
INSERT INTO `intent_step_transition` (`id`, `intent_id`, `from_step_id`, `to_step_id`, `branch_code`, `condition_json`, `priority`, `is_default`) VALUES (139, 100, 69, 70, 'DEFAULT', NULL, 1, 1);
INSERT INTO `intent_step_transition` (`id`, `intent_id`, `from_step_id`, `to_step_id`, `branch_code`, `condition_json`, `priority`, `is_default`) VALUES (140, 100, 70, 71, 'DEFAULT', NULL, 1, 1);
INSERT INTO `intent_step_transition` (`id`, `intent_id`, `from_step_id`, `to_step_id`, `branch_code`, `condition_json`, `priority`, `is_default`) VALUES (141, 100, 71, 72, 'DEFAULT', NULL, 1, 1);


INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (13, 100, NULL, 'applicant_profile', '申请人基本信息', 'OBJECT', NULL, NULL, '2026-02-15 15:32:53', '2026-02-15 15:32:53');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (14, 100, 13, 'name', '姓名', 'STRING', NULL, NULL, '2026-02-15 15:33:25', '2026-02-15 15:33:25');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (15, 100, 13, 'mobile', '手机号', 'STRING', NULL, NULL, '2026-02-15 15:33:36', '2026-02-15 15:33:36');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (16, 100, 13, 'identity_info', '身份标识', 'OBJECT', NULL, NULL, '2026-02-15 15:34:03', '2026-02-15 15:34:03');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (17, 100, 16, 'card_no', '身份证号', 'STRING', NULL, NULL, '2026-02-15 15:34:15', '2026-02-15 15:34:15');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (18, 100, 16, 'address', '户籍地址', 'STRING', NULL, NULL, '2026-02-15 15:34:25', '2026-02-15 15:34:25');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (19, 100, 13, 'is_first_loan', '是否首次贷款', 'BOOLEAN', NULL, NULL, '2026-02-15 15:34:49', '2026-02-15 15:34:49');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (20, 100, NULL, 'income_streams', '工作与收入流水', 'ARRAY', NULL, NULL, '2026-02-15 15:35:10', '2026-02-15 15:35:10');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (21, 100, 20, 'Item', '用于校验用户的还款能力', 'OBJECT', NULL, NULL, '2026-02-15 15:36:06', '2026-02-15 15:36:06');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (22, 100, 21, 'source_name', '收入来源（如：工资、理财、兼职）', 'STRING', NULL, NULL, '2026-02-15 15:36:20', '2026-02-15 15:36:20');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (23, 100, 21, 'amount', '月均金额', 'NUMBER', NULL, NULL, '2026-02-15 15:36:33', '2026-02-15 15:36:33');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (24, 100, 21, 'has_proof', '是否有纳税证明', 'BOOLEAN', NULL, NULL, '2026-02-15 15:36:47', '2026-02-15 15:36:47');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (25, 100, NULL, 'loan_request', '贷款意向需求，存储用户本次想要申请的贷款参数', 'OBJECT', NULL, NULL, '2026-02-15 15:37:17', '2026-02-15 15:37:17');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (26, 100, 25, 'amount', '申请总金额', 'NUMBER', NULL, NULL, '2026-02-15 15:37:36', '2026-02-15 15:37:36');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (27, 100, 25, 'term_months', '贷款期限（月）', 'NUMBER', NULL, NULL, '2026-02-15 15:37:52', '2026-02-15 15:37:52');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (28, 100, 25, 'category', '贷款用途（装修、购车、经营）', 'STRING', NULL, NULL, '2026-02-15 15:38:02', '2026-02-15 15:38:02');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (29, 100, NULL, 'risk_assessment', '风险控制评估', 'OBJECT', NULL, NULL, '2026-02-15 15:38:21', '2026-02-15 15:38:21');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (30, 100, 29, 'credit_score', '信用评分', 'NUMBER', NULL, NULL, '2026-02-15 15:38:38', '2026-02-15 15:38:38');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (31, 100, 29, 'is_in_blacklist', '是否在黑名单', 'BOOLEAN', NULL, NULL, '2026-02-15 15:38:50', '2026-02-15 15:38:50');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (32, 100, 29, 'suggested_rate', '系统建议利率', 'NUMBER', NULL, NULL, '2026-02-15 15:39:06', '2026-02-15 15:39:06');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (33, 100, NULL, 'repayment_schedule', '还款计划预览', 'ARRAY', NULL, NULL, '2026-02-15 15:39:27', '2026-02-15 15:39:27');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (34, 100, 33, 'Item', '根据贷款额和利率生成的详细列表', 'OBJECT', NULL, NULL, '2026-02-15 15:39:52', '2026-02-15 15:40:00');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (35, 100, 34, 'period', '期数', 'NUMBER', NULL, NULL, '2026-02-15 15:40:16', '2026-02-15 15:40:16');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (36, 100, 34, 'monthly_payment', '本月应还金额', 'NUMBER', NULL, NULL, '2026-02-15 15:40:31', '2026-02-15 15:40:31');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (37, 100, 34, 'due_date', '还款日期', 'STRING', NULL, NULL, '2026-02-15 15:40:49', '2026-02-15 15:40:49');
INSERT INTO `flow_variable` (`id`, `intent_id`, `parent_id`, `name`, `description`, `type`, `is_required`, `default_value`, `created_at`, `updated_at`) VALUES (38, 100, NULL, 'is_confirmed', '是否确认办理贷款', 'BOOLEAN', NULL, NULL, '2026-02-16 11:15:11', '2026-02-16 11:15:11');















