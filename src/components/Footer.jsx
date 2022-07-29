function Link({ uri, text }) {
  return <a href={uri} target="_blank" rel="noreferrer">{text}</a>;
}

function Footer() {
  return (
    <footer>
      <h2>Projet 3</h2>
      <h5>Réalisé par Guillaume Lierville</h5>
    </footer >
  );
}

export default Footer;
