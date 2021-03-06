describe('pw-strength', () => {
  let getForbiddenPasswords;
  before(async () => {
    window.LoginGov = { I18n: { t() {} } };
    ({ getForbiddenPasswords } = await import('../../../app/javascript/packs/pw-strength'));
  });

  after(() => {
    delete window.LoginGov;
  });

  describe('getForbiddenPasswords', () => {
    it('returns empty array if given argument is null', () => {
      const element = null;
      const result = getForbiddenPasswords(element);

      expect(result).to.deep.equal([]);
    });

    it('returns empty array if element has absent dataset value', () => {
      const element = document.createElement('span');
      const result = getForbiddenPasswords(element);

      expect(result).to.deep.equal([]);
    });

    it('returns empty array if element has invalid dataset value', () => {
      const element = document.createElement('span');
      element.setAttribute('data-forbidden', 'nil');
      const result = getForbiddenPasswords(element);

      expect(result).to.deep.equal([]);
    });

    it('parsed array of forbidden passwords', () => {
      const element = document.createElement('span');
      element.setAttribute('data-forbidden', '["foo","bar","baz"]');
      const result = getForbiddenPasswords(element);

      expect(result).to.be.deep.equal(['foo', 'bar', 'baz']);
    });
  });
});
