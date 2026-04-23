import { homedir } from "node:os";
import { basename, relative, sep } from "node:path";
import {
	DefaultResourceLoader,
	getAgentDir,
	SettingsManager,
	type ExtensionAPI,
	type ResourceDiagnostic,
	type SourceInfo,
} from "@mariozechner/pi-coding-agent";

function formatPath(path: string | undefined, cwd: string): string {
	if (!path) return "(unknown)";
	if (path.startsWith("<") && path.endsWith(">")) return path;

	const home = homedir();
	if (path === cwd) return ".";
	if (path === home) return "~";
	if (path.startsWith(`${home}${sep}`)) return `~/${path.slice(home.length + 1)}`;

	const rel = relative(cwd, path);
	if (rel && rel !== "" && !rel.startsWith("..") && !rel.includes(`${sep}..${sep}`) && rel !== "..") {
		return `./${rel}`;
	}

	return path;
}

function formatSourceInfo(sourceInfo: SourceInfo | undefined, cwd: string): string {
	if (!sourceInfo) return "";
	const details = [sourceInfo.scope, sourceInfo.origin];
	if (sourceInfo.source && sourceInfo.source !== sourceInfo.path) {
		details.push(sourceInfo.source);
	}
	return ` [${details.join(" · ")}] ${formatPath(sourceInfo.path, cwd)}`;
}

function formatDiagnostic(diag: ResourceDiagnostic, cwd: string): string {
	const location = diag.path ? ` (${formatPath(diag.path, cwd)})` : "";
	if (diag.type === "collision" && diag.collision) {
		return `- [collision] ${diag.collision.resourceType} \"${diag.collision.name}\" → kept ${formatPath(diag.collision.winnerPath, cwd)}, skipped ${formatPath(diag.collision.loserPath, cwd)}`;
	}
	return `- [${diag.type}] ${diag.message}${location}`;
}

function section(title: string, lines: string[]): string[] {
	return [`## ${title}`, ...(lines.length ? lines : ["(none)"]), ""];
}

export default function (pi: ExtensionAPI) {
	pi.registerCommand("resources", {
		description: "Show loaded Pi context files, extensions, skills, prompts, themes, commands, and tools",
		handler: async (_args, ctx) => {
			const settingsManager = SettingsManager.create(ctx.cwd, getAgentDir());
			const loader = new DefaultResourceLoader({
				cwd: ctx.cwd,
				agentDir: getAgentDir(),
				settingsManager,
			});
			await loader.reload();

			const extensionsResult = loader.getExtensions();
			const skillsResult = loader.getSkills();
			const promptsResult = loader.getPrompts();
			const themesResult = loader.getThemes();
			const contextFiles = loader.getAgentsFiles().agentsFiles;

			const commands = pi
				.getCommands()
				.slice()
				.sort((a, b) => a.name.localeCompare(b.name));
			const activeTools = new Set(pi.getActiveTools());
			const tools = pi
				.getAllTools()
				.slice()
				.sort((a, b) => a.name.localeCompare(b.name));

			const extensions = extensionsResult.extensions
				.slice()
				.sort((a, b) => a.path.localeCompare(b.path))
				.map((extension) => {
					const label = extension.sourceInfo?.source || basename(extension.path);
					return `- ${label}${formatSourceInfo(extension.sourceInfo, ctx.cwd)}`;
				});

			const skillLines = skillsResult.skills
				.slice()
				.sort((a, b) => a.name.localeCompare(b.name))
				.map((skill) => `- ${skill.name} — ${skill.description}${formatSourceInfo(skill.sourceInfo, ctx.cwd)}`);

			const promptLines = promptsResult.prompts
				.slice()
				.sort((a, b) => a.name.localeCompare(b.name))
				.map((prompt) => `- /${prompt.name} — ${prompt.description}${formatSourceInfo(prompt.sourceInfo, ctx.cwd)}`);

			const themeLines = themesResult.themes
				.slice()
				.sort((a, b) => (a.name || "").localeCompare(b.name || ""))
				.map((theme) => `- ${theme.name || "(unnamed)"}${theme.sourceInfo ? formatSourceInfo(theme.sourceInfo, ctx.cwd) : theme.sourcePath ? ` ${formatPath(theme.sourcePath, ctx.cwd)}` : ""}`);

			const contextLines = contextFiles
				.slice()
				.sort((a, b) => a.path.localeCompare(b.path))
				.map((file) => `- ${formatPath(file.path, ctx.cwd)}`);

			const commandLines = commands.map((command) => {
				const description = command.description ? ` — ${command.description}` : "";
				return `- /${command.name} [${command.source}]${description}${formatSourceInfo(command.sourceInfo, ctx.cwd)}`;
			});

			const toolLines = tools.map((tool) => {
				const active = activeTools.has(tool.name) ? "active" : "inactive";
				return `- ${tool.name} [${active}] — ${tool.description}${formatSourceInfo(tool.sourceInfo, ctx.cwd)}`;
			});

			const diagnostics = [
				...extensionsResult.errors.map((error) => `- [extension-error] ${error.error} (${formatPath(error.path, ctx.cwd)})`),
				...skillsResult.diagnostics.map((diag) => formatDiagnostic(diag, ctx.cwd)),
				...promptsResult.diagnostics.map((diag) => formatDiagnostic(diag, ctx.cwd)),
				...themesResult.diagnostics.map((diag) => formatDiagnostic(diag, ctx.cwd)),
			];

			const report = [
				"Pi resource snapshot",
				`cwd: ${formatPath(ctx.cwd, ctx.cwd)}`,
				"",
				...section("Context files", contextLines),
				...section("Extensions", extensions),
				...section("Skills", skillLines),
				...section("Prompt templates", promptLines),
				...section("Themes", themeLines),
				...section("Commands", commandLines),
				...section("Tools", toolLines),
				...section("Diagnostics", diagnostics),
			].join("\n");

			if (!ctx.hasUI) {
				return;
			}

			await ctx.ui.editor("Pi resources", report);
		},
	});
}
