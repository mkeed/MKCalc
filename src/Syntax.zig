const programSyntax = [_]SyntaxInfo{
    repeating(declaration),
    .EndOfInput,
};

const declaration = [_]SyntaxInfo{ funDecl, varDecl };
