local testsuite = Tests.Testsuite()
testsuite.name = "Mod API tests"

-- ///////////////////////////////////////////////////////////////
-- I/O Tests
testsuite.io = Tests.Testsuite()
testsuite.io.name = "I/O"

function testsuite.io.test_FileExistsSlashes()
	Assert.True(modApi:fileExists("./scripts/scripts.lua"))

	return true
end

function testsuite.io.test_FileExistsBackslashes()
	Assert.True(modApi:fileExists(".\\scripts\\scripts.lua"))

	return true
end

function testsuite.io.test_FileExistsMixed()
	Assert.True(modApi:fileExists(".\\scripts/scripts.lua"))

	return true
end

function testsuite.io.test_FileNotExistsGenerated()
	local name = os.date() .. modApi.timer:elapsed()
	Assert.False(modApi:fileExists("./tests/"..name))

	return true
end

function testsuite.io.test_DirectoryExistsSlashes()
	Assert.True(modApi:directoryExists("./scripts/mod_loader"))

	return true
end

function testsuite.io.test_DirectoryExistsBackslashes()
	Assert.True(modApi:directoryExists("./scripts/mod_loader"))

	return true
end

function testsuite.io.test_DirectoryExistsMixed()
	Assert.True(modApi:directoryExists(".\\scripts/mod_loader"))

	return true
end

function testsuite.io.test_DirectoryExistsCurrentDirectory()
	Assert.True(modApi:directoryExists("./scripts/."))

	return true
end

function testsuite.io.test_DirectoryExistsParentDirectory()
	Assert.True(modApi:directoryExists("./scripts/.."))

	return true
end

function testsuite.io.test_DirectoryNotExistsGenerated()
	local name = os.date() .. modApi.timer:elapsed()
	Assert.False(modApi:directoryExists("./tests/"..name))

	return true
end

function testsuite.io.test_GetFileNameSlashes()
	Assert.Equals("mod_loader", GetFileName("./scripts/mod_loader"))

	return true
end

function testsuite.io.test_GetFileNameBackslashes()
	Assert.Equals("mod_loader", GetFileName(".\\scripts\\mod_loader"))

	return true
end

function testsuite.io.test_GetFileNameMixed()
	Assert.Equals("mod_loader", GetFileName(".\\scripts/mod_loader"))

	return true
end

function testsuite.io.test_GetFileNameEmpty()
	Assert.Equals(nil, GetFileName(".\\scripts/mod_loader/"))

	return true
end

-- ///////////////////////////////////////////////////////////////
-- Unsorted Tests

function testsuite.test_GetParentPathTerminatedSlashes()
	Assert.Equals("./scripts/", GetParentPath("./scripts/mod_loader/"))

	return true
end

function testsuite.test_GetParentPathNonTerminatedSlashes()
	Assert.Equals("./scripts/", GetParentPath("./scripts/mod_loader"))

	return true
end

function testsuite.test_GetParentPathTerminatedBackslashes()
	Assert.Equals(".\\scripts\\", GetParentPath(".\\scripts\\mod_loader\\"))

	return true
end

function testsuite.test_GetParentPathNonTerminatedBackslashes()
	Assert.Equals(".\\scripts\\", GetParentPath(".\\scripts\\mod_loader"))

	return true
end

function testsuite.test_GetParentPathTerminatedMixed()
	Assert.Equals(".\\scripts/", GetParentPath(".\\scripts/mod_loader/"))

	return true
end

function testsuite.test_GetParentPathNonTerminatedMixed()
	Assert.Equals(".\\scripts/", GetParentPath(".\\scripts/mod_loader"))

	return true
end

return testsuite
